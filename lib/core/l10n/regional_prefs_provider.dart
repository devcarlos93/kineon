import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_client.dart';

// ============================================================================
// REGIONAL PREFERENCES - Soporte Multi-País para TMDB
// ============================================================================
// - countryCode: ISO 3166-1 alpha-2 (CO, MX, ES, AR, US...)
// - languageTag: IETF BCP 47 (es-CO, es-MX, en-US...)
//
// Uso:
// - language: para títulos, sinopsis, textos de UI
// - region: para watch providers, filtros por país, estrenos
// ============================================================================

const _countryCodeKey = 'regional_country_code';
const _languageTagKey = 'regional_language_tag';

/// Estado de preferencias regionales
class RegionalPrefs {
  final String countryCode;
  final String languageTag;

  const RegionalPrefs({
    required this.countryCode,
    required this.languageTag,
  });

  /// Defaults basados en España
  static const defaultPrefs = RegionalPrefs(
    countryCode: 'ES',
    languageTag: 'es-ES',
  );

  /// Crea RegionalPrefs desde el locale del dispositivo
  factory RegionalPrefs.fromDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final countryCode = deviceLocale.countryCode ?? 'ES';
    final languageTag = deviceLocale.toLanguageTag();

    return RegionalPrefs(
      countryCode: countryCode.toUpperCase(),
      languageTag: languageTag,
    );
  }

  /// Obtiene solo el código de idioma (sin país) para TMDB
  /// ej: "es-CO" -> "es"
  String get languageCode => languageTag.split('-').first;

  /// Formato para TMDB API
  /// Algunos endpoints usan "es-CO", otros solo "es"
  String get tmdbLanguage => languageTag;

  /// Región para TMDB (watch providers, etc.)
  String get tmdbRegion => countryCode;

  RegionalPrefs copyWith({
    String? countryCode,
    String? languageTag,
  }) {
    return RegionalPrefs(
      countryCode: countryCode ?? this.countryCode,
      languageTag: languageTag ?? this.languageTag,
    );
  }

  Map<String, dynamic> toJson() => {
        'country_code': countryCode,
        'language_tag': languageTag,
      };

  factory RegionalPrefs.fromJson(Map<String, dynamic> json) {
    return RegionalPrefs(
      countryCode: json['country_code'] as String? ?? 'ES',
      languageTag: json['language_tag'] as String? ?? 'es-ES',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionalPrefs &&
          countryCode == other.countryCode &&
          languageTag == other.languageTag;

  @override
  int get hashCode => Object.hash(countryCode, languageTag);

  @override
  String toString() =>
      'RegionalPrefs(countryCode: $countryCode, languageTag: $languageTag)';
}

/// Provider de preferencias regionales
final regionalPrefsProvider =
    StateNotifierProvider<RegionalPrefsNotifier, RegionalPrefs>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return RegionalPrefsNotifier(supabase);
});

/// Notifier para gestionar preferencias regionales
class RegionalPrefsNotifier extends StateNotifier<RegionalPrefs> {
  final SupabaseClient _supabase;
  bool _initialized = false;

  RegionalPrefsNotifier(this._supabase) : super(RegionalPrefs.defaultPrefs) {
    _initialize();
  }

  bool get isInitialized => _initialized;

  /// Inicializa las preferencias (orden de prioridad):
  /// 1. Supabase profiles (si autenticado)
  /// 2. SharedPreferences local
  /// 3. Locale del dispositivo
  Future<void> _initialize() async {
    try {
      // 1. Intentar cargar desde Supabase si hay usuario
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final prefs = await _loadFromSupabase(user.id);
        if (prefs != null) {
          state = prefs;
          _initialized = true;
          return;
        }
      }

      // 2. Intentar cargar desde SharedPreferences
      final localPrefs = await _loadFromLocal();
      if (localPrefs != null) {
        state = localPrefs;
        _initialized = true;
        return;
      }

      // 3. Usar locale del dispositivo
      state = RegionalPrefs.fromDeviceLocale();
      _initialized = true;

      // Guardar localmente para próximas sesiones
      await _saveToLocal(state);
    } catch (_) {
      // En caso de error, usar locale del dispositivo
      state = RegionalPrefs.fromDeviceLocale();
      _initialized = true;
    }
  }

  /// Carga preferencias desde Supabase
  Future<RegionalPrefs?> _loadFromSupabase(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('country_code, language_tag')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      final countryCode = response['country_code'] as String?;
      final languageTag = response['language_tag'] as String?;

      // Si no tiene valores, retornar null para usar fallback
      if (countryCode == null && languageTag == null) return null;

      return RegionalPrefs(
        countryCode: countryCode ?? 'ES',
        languageTag: languageTag ?? 'es-ES',
      );
    } catch (e) {
      return null;
    }
  }

  /// Carga preferencias desde SharedPreferences
  Future<RegionalPrefs?> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final countryCode = prefs.getString(_countryCodeKey);
      final languageTag = prefs.getString(_languageTagKey);

      if (countryCode == null && languageTag == null) return null;

      return RegionalPrefs(
        countryCode: countryCode ?? 'ES',
        languageTag: languageTag ?? 'es-ES',
      );
    } catch (e) {
      return null;
    }
  }

  /// Guarda preferencias en SharedPreferences
  Future<void> _saveToLocal(RegionalPrefs prefs) async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setString(_countryCodeKey, prefs.countryCode);
      await sharedPrefs.setString(_languageTagKey, prefs.languageTag);
    } catch (e) {
      // Ignorar errores de guardado local
    }
  }

  /// Guarda preferencias en Supabase
  Future<void> _saveToSupabase(RegionalPrefs prefs) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'country_code': prefs.countryCode,
        'language_tag': prefs.languageTag,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error pero no fallar
    }
  }

  /// Actualiza las preferencias regionales
  Future<void> setRegionalPrefs(RegionalPrefs prefs) async {
    state = prefs;
    await Future.wait([
      _saveToLocal(prefs),
      _saveToSupabase(prefs),
    ]);
  }

  /// Actualiza solo el país (ajusta automáticamente el languageTag)
  Future<void> setCountry(String countryCode) async {
    final languageTag = _inferLanguageTag(countryCode);
    await setRegionalPrefs(RegionalPrefs(
      countryCode: countryCode,
      languageTag: languageTag,
    ));
  }

  /// Infiere el language tag basado en el país
  String _inferLanguageTag(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'US':
      case 'GB':
      case 'AU':
      case 'CA':
        return 'en-$countryCode';
      case 'BR':
        return 'pt-BR';
      case 'PT':
        return 'pt-PT';
      case 'FR':
        return 'fr-FR';
      case 'DE':
      case 'AT':
      case 'CH':
        return 'de-$countryCode';
      case 'IT':
        return 'it-IT';
      // Países hispanohablantes
      case 'ES':
      case 'MX':
      case 'CO':
      case 'AR':
      case 'CL':
      case 'PE':
      case 'VE':
      case 'EC':
      case 'BO':
      case 'PY':
      case 'UY':
      case 'CR':
      case 'PA':
      case 'DO':
      case 'GT':
      case 'HN':
      case 'SV':
      case 'NI':
      case 'CU':
      case 'PR':
        return 'es-$countryCode';
      default:
        return 'es-ES';
    }
  }

  /// Recarga las preferencias desde Supabase
  Future<void> refresh() async {
    _initialized = false;
    await _initialize();
  }
}

/// Provider helper para obtener solo el languageTag (para TMDB)
final tmdbLanguageProvider = Provider<String>((ref) {
  return ref.watch(regionalPrefsProvider).tmdbLanguage;
});

/// Provider helper para obtener solo la región (para TMDB)
final tmdbRegionProvider = Provider<String>((ref) {
  return ref.watch(regionalPrefsProvider).tmdbRegion;
});

/// Lista de países soportados con sus nombres
class SupportedCountry {
  final String code;
  final String name;
  final String flag;

  const SupportedCountry(this.code, this.name, this.flag);
}

const supportedCountries = [
  // Latinoamérica
  SupportedCountry('MX', 'México', '🇲🇽'),
  SupportedCountry('CO', 'Colombia', '🇨🇴'),
  SupportedCountry('AR', 'Argentina', '🇦🇷'),
  SupportedCountry('CL', 'Chile', '🇨🇱'),
  SupportedCountry('PE', 'Perú', '🇵🇪'),
  SupportedCountry('VE', 'Venezuela', '🇻🇪'),
  SupportedCountry('EC', 'Ecuador', '🇪🇨'),
  SupportedCountry('CR', 'Costa Rica', '🇨🇷'),
  SupportedCountry('PA', 'Panamá', '🇵🇦'),
  SupportedCountry('DO', 'República Dominicana', '🇩🇴'),
  // España
  SupportedCountry('ES', 'España', '🇪🇸'),
  // USA
  SupportedCountry('US', 'United States', '🇺🇸'),
];
