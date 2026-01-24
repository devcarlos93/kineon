import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/supabase_client.dart';

// Re-export para conveniencia
export '../../../../core/constants/app_constants.dart' show ContentType, WatchStatus;

/// Estado de una película/serie para el usuario
class MediaState {
  final String id;
  final int tmdbId;
  final ContentType contentType;
  final WatchStatus status;
  final bool isFavorite;
  final int? currentSeason;
  final int? currentEpisode;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime updatedAt;

  const MediaState({
    required this.id,
    required this.tmdbId,
    required this.contentType,
    required this.status,
    required this.isFavorite,
    this.currentSeason,
    this.currentEpisode,
    required this.addedAt,
    this.startedAt,
    this.finishedAt,
    required this.updatedAt,
  });

  factory MediaState.fromJson(Map<String, dynamic> json) {
    return MediaState(
      id: json['id'] as String,
      tmdbId: json['tmdb_id'] as int,
      contentType: ContentType.fromString(json['content_type'] as String),
      status: WatchStatus.fromString(json['status'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
      currentSeason: json['current_season'] as int?,
      currentEpisode: json['current_episode'] as int?,
      addedAt: DateTime.parse(json['added_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Helpers para UI
  bool get isInWatchlist => status == WatchStatus.watchlist;
  bool get isWatching => status == WatchStatus.watching;
  bool get isWatched => status == WatchStatus.watched;

  MediaState copyWith({
    WatchStatus? status,
    bool? isFavorite,
    int? currentSeason,
    int? currentEpisode,
  }) {
    return MediaState(
      id: id,
      tmdbId: tmdbId,
      contentType: contentType,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      addedAt: addedAt,
      startedAt: startedAt,
      finishedAt: finishedAt,
      updatedAt: DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl(ref.watch(supabaseClientProvider));
});

// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════════════════════════════════

abstract class LibraryRepository {
  /// Obtiene el estado de un contenido específico
  Future<MediaState?> getMediaState(int tmdbId, ContentType contentType);

  /// Obtiene estados de múltiples contenidos (para micro-dos en listas)
  Future<Map<int, MediaState>> getMediaStates(
    List<int> tmdbIds,
    ContentType contentType,
  );

  /// Obtiene todos los items del watchlist
  Future<List<MediaState>> getWatchlist({ContentType? contentType});

  /// Obtiene todos los favoritos
  Future<List<MediaState>> getFavorites({ContentType? contentType});

  /// Obtiene todos los vistos
  Future<List<MediaState>> getWatched({ContentType? contentType});

  /// Agrega a watchlist
  Future<MediaState> addToWatchlist(int tmdbId, ContentType contentType);

  /// Quita del watchlist
  Future<void> removeFromWatchlist(int tmdbId, ContentType contentType);

  /// Toggle favorito
  Future<MediaState> toggleFavorite(int tmdbId, ContentType contentType);

  /// Marcar como visto
  Future<MediaState> markAsWatched(int tmdbId, ContentType contentType);

  /// Quitar de vistos
  Future<void> removeFromWatched(int tmdbId, ContentType contentType);

  /// Actualizar estado completo
  Future<MediaState> updateMediaState({
    required int tmdbId,
    required ContentType contentType,
    WatchStatus? status,
    bool? isFavorite,
    int? currentSeason,
    int? currentEpisode,
  });

  /// Eliminar estado (quita de todo)
  Future<void> deleteMediaState(int tmdbId, ContentType contentType);

  /// Stream de cambios para un contenido específico
  Stream<MediaState?> watchMediaState(int tmdbId, ContentType contentType);

  /// Obtener estadísticas del usuario
  Future<LibraryStats> getStats();

  /// Obtener actividad de visualización para el heatmap (últimos 6 meses)
  Future<ViewingActivity> getViewingActivity();
}

/// Actividad de visualización para el heatmap
class ViewingActivity {
  final List<int> activityLevels; // 0-4 por cada celda (24 celdas = 6 meses x 4 semanas)
  final int totalWatched;
  final int changePercentage; // vs periodo anterior

  const ViewingActivity({
    required this.activityLevels,
    required this.totalWatched,
    required this.changePercentage,
  });

  static const empty = ViewingActivity(
    activityLevels: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    totalWatched: 0,
    changePercentage: 0,
  );
}

/// Estadísticas de la biblioteca
class LibraryStats {
  final int watchlistCount;
  final int favoritesCount;
  final int watchedCount;
  final int watchingCount;

  const LibraryStats({
    required this.watchlistCount,
    required this.favoritesCount,
    required this.watchedCount,
    required this.watchingCount,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════

class LibraryRepositoryImpl implements LibraryRepository {
  final SupabaseClient _client;

  LibraryRepositoryImpl(this._client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<MediaState?> getMediaState(int tmdbId, ContentType contentType) async {
    try {
      final response = await _client
          .from('user_movie_state')
          .select()
          .eq('user_id', _userId)
          .eq('tmdb_id', tmdbId)
          .eq('content_type', contentType.value)
          .maybeSingle();

      if (response == null) return null;
      return MediaState.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<int, MediaState>> getMediaStates(
    List<int> tmdbIds,
    ContentType contentType,
  ) async {
    if (tmdbIds.isEmpty) return {};

    try {
      final response = await _client
          .from('user_movie_state')
          .select()
          .eq('user_id', _userId)
          .eq('content_type', contentType.value)
          .inFilter('tmdb_id', tmdbIds);

      final Map<int, MediaState> result = {};
      for (final item in response as List) {
        final state = MediaState.fromJson(item as Map<String, dynamic>);
        result[state.tmdbId] = state;
      }
      return result;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MediaState>> getWatchlist({ContentType? contentType}) async {
    return _getByStatus(WatchStatus.watchlist, contentType: contentType);
  }

  @override
  Future<List<MediaState>> getFavorites({ContentType? contentType}) async {
    try {
      var query = _client
          .from('user_movie_state')
          .select()
          .eq('user_id', _userId)
          .eq('is_favorite', true);

      if (contentType != null) {
        query = query.eq('content_type', contentType.value);
      }

      final response = await query.order('updated_at', ascending: false);
      return (response as List)
          .map((item) => MediaState.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MediaState>> getWatched({ContentType? contentType}) async {
    return _getByStatus(WatchStatus.watched, contentType: contentType);
  }

  Future<List<MediaState>> _getByStatus(
    WatchStatus status, {
    ContentType? contentType,
  }) async {
    try {
      var query = _client
          .from('user_movie_state')
          .select()
          .eq('user_id', _userId)
          .eq('status', status.value);

      if (contentType != null) {
        query = query.eq('content_type', contentType.value);
      }

      final response = await query.order('updated_at', ascending: false);
      return (response as List)
          .map((item) => MediaState.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MediaState> addToWatchlist(int tmdbId, ContentType contentType) async {
    return _upsertState(
      tmdbId: tmdbId,
      contentType: contentType,
      status: WatchStatus.watchlist,
    );
  }

  @override
  Future<void> removeFromWatchlist(int tmdbId, ContentType contentType) async {
    final state = await getMediaState(tmdbId, contentType);
    if (state == null) return;

    // Si solo está en watchlist y no es favorito, eliminar completamente
    if (state.status == WatchStatus.watchlist && !state.isFavorite) {
      await deleteMediaState(tmdbId, contentType);
    } else {
      // Si es favorito, cambiar estado a watched
      await _upsertState(
        tmdbId: tmdbId,
        contentType: contentType,
        status: WatchStatus.watched,
      );
    }
  }

  @override
  Future<MediaState> toggleFavorite(int tmdbId, ContentType contentType) async {
    final current = await getMediaState(tmdbId, contentType);
    final newIsFavorite = !(current?.isFavorite ?? false);

    // Si no existe y vamos a marcar como favorito, crearlo con status "none"
    // (solo favorito, no en watchlist)
    if (current == null && newIsFavorite) {
      return _upsertState(
        tmdbId: tmdbId,
        contentType: contentType,
        status: WatchStatus.none,
        isFavorite: true,
      );
    }

    // Si existe, solo actualizar el flag de favorito
    if (current != null) {
      // Si quitamos favorito y el status es "none", eliminar el registro
      if (!newIsFavorite && current.status == WatchStatus.none) {
        await deleteMediaState(tmdbId, contentType);
        // Retornar un estado "vacío" para indicar que se eliminó
        return MediaState(
          id: current.id,
          tmdbId: tmdbId,
          contentType: contentType,
          status: WatchStatus.none,
          isFavorite: false,
          addedAt: current.addedAt,
          updatedAt: DateTime.now(),
        );
      }
      return _upsertState(
        tmdbId: tmdbId,
        contentType: contentType,
        status: current.status,
        isFavorite: newIsFavorite,
      );
    }

    // No debería llegar aquí
    throw ServerException(message: 'Estado inválido');
  }

  @override
  Future<MediaState> markAsWatched(int tmdbId, ContentType contentType) async {
    final current = await getMediaState(tmdbId, contentType);
    return _upsertState(
      tmdbId: tmdbId,
      contentType: contentType,
      status: WatchStatus.watched,
      isFavorite: current?.isFavorite ?? false,
      finishedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeFromWatched(int tmdbId, ContentType contentType) async {
    final state = await getMediaState(tmdbId, contentType);
    if (state == null) return;

    // Si es favorito, mantener pero cambiar status
    if (state.isFavorite) {
      await _upsertState(
        tmdbId: tmdbId,
        contentType: contentType,
        status: WatchStatus.watchlist,
        isFavorite: true,
      );
    } else {
      // Si solo estaba marcado como visto, eliminar
      await deleteMediaState(tmdbId, contentType);
    }
  }

  @override
  Future<MediaState> updateMediaState({
    required int tmdbId,
    required ContentType contentType,
    WatchStatus? status,
    bool? isFavorite,
    int? currentSeason,
    int? currentEpisode,
  }) async {
    final current = await getMediaState(tmdbId, contentType);
    return _upsertState(
      tmdbId: tmdbId,
      contentType: contentType,
      status: status ?? current?.status ?? WatchStatus.watchlist,
      isFavorite: isFavorite ?? current?.isFavorite ?? false,
      currentSeason: currentSeason ?? current?.currentSeason,
      currentEpisode: currentEpisode ?? current?.currentEpisode,
      startedAt: status == WatchStatus.watching ? DateTime.now() : current?.startedAt,
      finishedAt: status == WatchStatus.watched ? DateTime.now() : current?.finishedAt,
    );
  }

  Future<MediaState> _upsertState({
    required int tmdbId,
    required ContentType contentType,
    required WatchStatus status,
    bool? isFavorite,
    int? currentSeason,
    int? currentEpisode,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) async {
    try {
      final data = {
        'user_id': _userId,
        'tmdb_id': tmdbId,
        'content_type': contentType.value,
        'status': status.value,
        'is_favorite': isFavorite ?? false,
        if (currentSeason != null) 'current_season': currentSeason,
        if (currentEpisode != null) 'current_episode': currentEpisode,
        if (startedAt != null) 'started_at': startedAt.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt.toIso8601String(),
      };

      final response = await _client
          .from('user_movie_state')
          .upsert(
            data,
            onConflict: 'user_id,tmdb_id,content_type',
          )
          .select()
          .single();

      return MediaState.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteMediaState(int tmdbId, ContentType contentType) async {
    try {
      await _client
          .from('user_movie_state')
          .delete()
          .eq('user_id', _userId)
          .eq('tmdb_id', tmdbId)
          .eq('content_type', contentType.value);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<MediaState?> watchMediaState(int tmdbId, ContentType contentType) {
    return _client
        .from('user_movie_state')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .map((list) {
          final match = list.where((item) =>
              item['tmdb_id'] == tmdbId &&
              item['content_type'] == contentType.value);
          if (match.isEmpty) return null;
          return MediaState.fromJson(match.first);
        });
  }

  @override
  Future<LibraryStats> getStats() async {
    try {
      final response = await _client
          .from('user_movie_state')
          .select('status, is_favorite')
          .eq('user_id', _userId);

      final items = response as List;

      int watchlist = 0;
      int favorites = 0;
      int watched = 0;
      int watching = 0;

      for (final item in items) {
        final status = item['status'] as String;
        final isFavorite = item['is_favorite'] as bool? ?? false;

        if (status == 'watchlist') watchlist++;
        if (status == 'watched') watched++;
        if (status == 'watching') watching++;
        if (isFavorite) favorites++;
      }

      return LibraryStats(
        watchlistCount: watchlist,
        favoritesCount: favorites,
        watchedCount: watched,
        watchingCount: watching,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ViewingActivity> getViewingActivity() async {
    try {
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      final twelveMonthsAgo = now.subtract(const Duration(days: 360));

      // Obtener items vistos en los últimos 6 meses
      final response = await _client
          .from('user_movie_state')
          .select('finished_at')
          .eq('user_id', _userId)
          .eq('status', 'watched')
          .not('finished_at', 'is', null)
          .gte('finished_at', sixMonthsAgo.toIso8601String());

      final items = response as List;

      // Obtener items del periodo anterior (6-12 meses atrás) para calcular cambio
      final previousResponse = await _client
          .from('user_movie_state')
          .select('finished_at')
          .eq('user_id', _userId)
          .eq('status', 'watched')
          .not('finished_at', 'is', null)
          .gte('finished_at', twelveMonthsAgo.toIso8601String())
          .lt('finished_at', sixMonthsAgo.toIso8601String());

      final previousItems = previousResponse as List;
      final currentCount = items.length;
      final previousCount = previousItems.length;

      // Calcular cambio porcentual
      int changePercentage = 0;
      if (previousCount > 0) {
        changePercentage = (((currentCount - previousCount) / previousCount) * 100).round();
      } else if (currentCount > 0) {
        changePercentage = 100;
      }

      // Crear grid de 24 celdas (6 columnas x 4 filas)
      // Cada celda representa ~1 semana
      final activityLevels = List<int>.filled(24, 0);
      final weekCounts = <int, int>{};

      for (final item in items) {
        final finishedAt = DateTime.parse(item['finished_at'] as String);
        final weekIndex = now.difference(finishedAt).inDays ~/ 7;
        if (weekIndex < 24) {
          weekCounts[weekIndex] = (weekCounts[weekIndex] ?? 0) + 1;
        }
      }

      // Determinar niveles (0-4) basado en la actividad relativa
      if (weekCounts.isNotEmpty) {
        final maxCount = weekCounts.values.reduce((a, b) => a > b ? a : b);
        for (final entry in weekCounts.entries) {
          final index = 23 - entry.key; // Invertir para que más reciente esté a la derecha
          if (index >= 0 && index < 24) {
            if (maxCount > 0) {
              activityLevels[index] = ((entry.value / maxCount) * 4).ceil().clamp(1, 4);
            }
          }
        }
      }

      return ViewingActivity(
        activityLevels: activityLevels,
        totalWatched: currentCount,
        changePercentage: changePercentage,
      );
    } catch (e) {
      // En caso de error, devolver vacío en lugar de fallar
      return ViewingActivity.empty;
    }
  }
}
