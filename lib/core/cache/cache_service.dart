import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Servicio de caché local usando Hive (Singleton)
class CacheService {
  // Singleton instance
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _tmdbBoxName = 'tmdb_cache';
  static const String _metaBoxName = 'cache_meta';

  // TTLs en minutos
  static const int ttlTrending = 120; // 2 horas
  static const int ttlPopular = 360; // 6 horas
  static const int ttlDetails = 1440; // 24 horas
  static const int ttlGenres = 10080; // 7 días
  static const int ttlAiPicks = 720; // 12 horas para AI picks

  Box<String>? _tmdbBox;
  Box<int>? _metaBox;
  bool _initialized = false;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _initialized;

  /// Inicializa Hive y abre los boxes
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _tmdbBox = await Hive.openBox<String>(_tmdbBoxName);
    _metaBox = await Hive.openBox<int>(_metaBoxName);
    _initialized = true;

    // Limpiar caché expirado en background
    _cleanExpiredCache();
  }

  /// Guarda datos en caché con TTL
  Future<void> put(String key, dynamic data, {int ttlMinutes = 360, bool flush = false}) async {
    if (!_initialized) return;

    try {
      final jsonString = jsonEncode(data);
      final expiresAt = DateTime.now().add(Duration(minutes: ttlMinutes)).millisecondsSinceEpoch;

      await _tmdbBox?.put(key, jsonString);
      await _metaBox?.put('${key}_expires', expiresAt);

      if (flush) {
        await _tmdbBox?.flush();
        await _metaBox?.flush();
      }
    } catch (_) {}
  }

  /// Obtiene datos del caché (null si no existe o expiró)
  T? get<T>(String key) {
    if (!_initialized) return null;

    try {
      final expiresAt = _metaBox?.get('${key}_expires');
      if (expiresAt == null) return null;

      // Verificar si expiró
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _tmdbBox?.delete(key);
        _metaBox?.delete('${key}_expires');
        return null;
      }

      final jsonString = _tmdbBox?.get(key);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as T;
    } catch (_) {
      return null;
    }
  }

  /// Obtiene datos del caché incluso si expiraron (para fallback offline)
  T? getStale<T>(String key) {
    if (!_initialized) return null;

    try {
      final jsonString = _tmdbBox?.get(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as T;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si existe en caché (sin importar si expiró)
  bool hasStaleData(String key) {
    if (!_initialized) return false;
    return _tmdbBox?.containsKey(key) ?? false;
  }

  /// Borra una entrada específica
  Future<void> delete(String key) async {
    if (!_initialized) return;
    await _tmdbBox?.delete(key);
    await _metaBox?.delete('${key}_expires');
  }

  /// Limpia todo el caché
  Future<void> clearAll() async {
    if (!_initialized) return;
    await _tmdbBox?.clear();
    await _metaBox?.clear();
  }

  /// Limpia entradas expiradas
  Future<void> _cleanExpiredCache() async {
    if (!_initialized) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final keysToDelete = <String>[];

      for (final key in _metaBox?.keys ?? <String>[]) {
        if (key is String && key.endsWith('_expires')) {
          final expiresAt = _metaBox?.get(key);
          if (expiresAt != null && now > expiresAt) {
            keysToDelete.add(key.replaceAll('_expires', ''));
          }
        }
      }

      for (final key in keysToDelete) {
        await _tmdbBox?.delete(key);
        await _metaBox?.delete('${key}_expires');
      }
    } catch (_) {}
  }

  /// Obtiene estadísticas del caché
  Map<String, int> getStats() {
    return {
      'entries': _tmdbBox?.length ?? 0,
      'sizeBytes': _tmdbBox?.keys.fold<int>(0, (sum, key) {
            final value = _tmdbBox?.get(key);
            return sum + (value?.length ?? 0);
          }) ??
          0,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CACHE KEYS HELPERS
// ═══════════════════════════════════════════════════════════════════════════

/// Generadores de keys para el caché
abstract class CacheKeys {
  static String trending(String mediaType, String timeWindow) =>
      'trending_${mediaType}_$timeWindow';

  static String popular(String mediaType) => 'popular_$mediaType';

  static String topRated(String mediaType) => 'top_rated_$mediaType';

  static String nowPlaying() => 'now_playing_movie';

  static String upcoming() => 'upcoming_movie';

  static String movieDetails(int id) => 'movie_details_$id';

  static String tvDetails(int id) => 'tv_details_$id';

  static String genres(String mediaType) => 'genres_$mediaType';

  static String watchProviders(int id, String mediaType) =>
      'watch_providers_${mediaType}_$id';
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});
