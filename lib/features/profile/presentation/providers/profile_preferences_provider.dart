import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/theme_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELO
// ═══════════════════════════════════════════════════════════════════════════

class ProfilePreferences {
  final bool hideSpoilers;
  final String countryCode;
  final String themeMode;
  final String preferredLanguage;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? memberSince;

  const ProfilePreferences({
    this.hideSpoilers = false,
    this.countryCode = 'US',
    this.themeMode = 'dark',
    this.preferredLanguage = 'es',
    this.displayName,
    this.avatarUrl,
    this.memberSince,
  });

  ProfilePreferences copyWith({
    bool? hideSpoilers,
    String? countryCode,
    String? themeMode,
    String? preferredLanguage,
    String? displayName,
    String? avatarUrl,
    DateTime? memberSince,
  }) {
    return ProfilePreferences(
      hideSpoilers: hideSpoilers ?? this.hideSpoilers,
      countryCode: countryCode ?? this.countryCode,
      themeMode: themeMode ?? this.themeMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  factory ProfilePreferences.fromJson(Map<String, dynamic> json) {
    return ProfilePreferences(
      hideSpoilers: json['hide_spoilers'] as bool? ?? false,
      countryCode: json['country_code'] as String? ?? 'US',
      themeMode: json['theme_mode'] as String? ?? 'dark',
      preferredLanguage: json['preferred_language'] as String? ?? 'es',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      memberSince: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════════════

class ProfilePreferencesState {
  final ProfilePreferences preferences;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfilePreferencesState({
    this.preferences = const ProfilePreferences(),
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProfilePreferencesState copyWith({
    ProfilePreferences? preferences,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProfilePreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

class ProfilePreferencesNotifier extends StateNotifier<ProfilePreferencesState> {
  final SupabaseClient _client;
  final Ref _ref;

  ProfilePreferencesNotifier(this._client, this._ref) : super(const ProfilePreferencesState()) {
    loadPreferences();
  }

  /// Carga las preferencias del usuario desde Supabase
  Future<void> loadPreferences() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _client
          .rpc('get_profile_preferences', params: {'p_user_id': userId})
          .timeout(const Duration(seconds: 10));

      if (result is List && result.isNotEmpty) {
        final prefs = ProfilePreferences.fromJson(result.first as Map<String, dynamic>);
        state = state.copyWith(
          preferences: prefs,
          isLoading: false,
        );
        // Sincronizar el idioma de la app con las preferencias del perfil
        _ref.read(localeProvider.notifier).setLocale(Locale(prefs.preferredLanguage));
        // Sincronizar la región y el idioma juntos para no perder el idioma del usuario
        _ref.read(regionalPrefsProvider.notifier).setRegionalPrefs(RegionalPrefs(
          countryCode: prefs.countryCode,
          languageTag: '${prefs.preferredLanguage}-${prefs.countryCode}',
        ));
        // Sincronizar el tema
        _ref.read(themeModeProvider.notifier).setThemeModeFromString(prefs.themeMode);
      } else {
        // No hay perfil aún, usar defaults
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Actualiza hide spoilers
  Future<void> setHideSpoilers(bool value) async {
    await _updatePreference(hideSpoilers: value);
  }

  /// Actualiza país/región de streaming
  Future<void> setCountryCode(String code) async {
    await _updatePreference(countryCode: code);
    // Actualizar el provider regional para TMDB
    // Los providers (home, aiPicks, smartCollections) se recrean automáticamente
    // via ref.watch(regionalPrefsProvider) en sus definiciones
    await _ref.read(regionalPrefsProvider.notifier).setCountry(code);
  }

  /// Actualiza modo de tema
  Future<void> setThemeMode(String mode) async {
    await _updatePreference(themeMode: mode);
    // Actualizar el provider de tema de la app
    _ref.read(themeModeProvider.notifier).setThemeModeFromString(mode);
  }

  /// Actualiza idioma preferido
  Future<void> setPreferredLanguage(String language) async {
    await _updatePreference(preferredLanguage: language);
    // Actualizar el locale de la app (UI)
    _ref.read(localeProvider.notifier).setLocale(Locale(language));
    // Actualizar regionalPrefs para TMDB (títulos, sinopsis, etc.)
    // Los providers (home, aiPicks, smartCollections) se recrean automáticamente
    // via ref.watch(regionalPrefsProvider) en sus definiciones
    await _ref.read(regionalPrefsProvider.notifier).setLanguage(language);
  }

  /// Método interno para actualizar preferencias
  Future<void> _updatePreference({
    bool? hideSpoilers,
    String? countryCode,
    String? themeMode,
    String? preferredLanguage,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Optimistic update
    state = state.copyWith(
      isSaving: true,
      preferences: state.preferences.copyWith(
        hideSpoilers: hideSpoilers,
        countryCode: countryCode,
        themeMode: themeMode,
        preferredLanguage: preferredLanguage,
      ),
    );

    try {
      await _client.rpc('update_profile_preferences', params: {
        'p_user_id': userId,
        if (hideSpoilers != null) 'p_hide_spoilers': hideSpoilers,
        if (countryCode != null) 'p_country_code': countryCode,
        if (themeMode != null) 'p_theme_mode': themeMode,
        if (preferredLanguage != null) 'p_preferred_language': preferredLanguage,
      }).timeout(const Duration(seconds: 10));

      state = state.copyWith(isSaving: false);
    } catch (e) {
      // Revertir en caso de error
      await loadPreferences();
      state = state.copyWith(
        isSaving: false,
        error: 'No se pudo guardar: $e',
      );
    }
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

final profilePreferencesProvider =
    StateNotifierProvider<ProfilePreferencesNotifier, ProfilePreferencesState>((ref) {
  return ProfilePreferencesNotifier(ref.watch(supabaseClientProvider), ref);
});

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════

/// Regiones disponibles para streaming
class StreamingRegionData {
  final String code;
  final String name;
  final String flag;

  const StreamingRegionData(this.code, this.name, this.flag);
}

const availableStreamingRegions = [
  StreamingRegionData('US', 'United States', '🇺🇸'),
  StreamingRegionData('MX', 'México', '🇲🇽'),
  StreamingRegionData('ES', 'España', '🇪🇸'),
  StreamingRegionData('CO', 'Colombia', '🇨🇴'),
  StreamingRegionData('AR', 'Argentina', '🇦🇷'),
  StreamingRegionData('CL', 'Chile', '🇨🇱'),
  StreamingRegionData('PE', 'Perú', '🇵🇪'),
  StreamingRegionData('GB', 'United Kingdom', '🇬🇧'),
  StreamingRegionData('DE', 'Germany', '🇩🇪'),
  StreamingRegionData('FR', 'France', '🇫🇷'),
  StreamingRegionData('BR', 'Brasil', '🇧🇷'),
];

StreamingRegionData getRegionByCode(String code) {
  return availableStreamingRegions.firstWhere(
    (r) => r.code == code,
    orElse: () => availableStreamingRegions.first,
  );
}
