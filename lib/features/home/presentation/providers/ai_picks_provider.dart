import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/media_item.dart';

/// Pick generado por IA con razon personalizada
class AIPick {
  final MediaItem item;
  final String reason;

  const AIPick({
    required this.item,
    required this.reason,
  });

  factory AIPick.fromJson(Map<String, dynamic> json) {
    return AIPick(
      item: MediaItem(
        id: json['tmdb_id'] as int,
        title: json['title'] as String? ?? 'Sin titulo',
        overview: json['overview'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: 0,
        genreIds: (json['genre_ids'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        contentType: json['content_type'] == 'tv'
            ? ContentType.tv
            : ContentType.movie,
        releaseDate: json['release_date'] as String?,
      ),
      reason: json['reason'] as String? ?? 'Recomendado para ti',
    );
  }

  /// Convierte a JSON para cache local
  Map<String, dynamic> toJson() {
    return {
      'tmdb_id': item.id,
      'title': item.title,
      'overview': item.overview,
      'poster_path': item.posterPath,
      'backdrop_path': item.backdropPath,
      'vote_average': item.voteAverage,
      'genre_ids': item.genreIds,
      'content_type': item.contentType == ContentType.tv ? 'tv' : 'movie',
      'release_date': item.releaseDate,
      'reason': reason,
    };
  }
}

/// Estado de los AI Picks
class AIPicksState {
  final List<AIPick> picks;
  final bool isLoading;
  final bool isRefreshing; // True cuando hay datos pero se está actualizando en background
  final String? error;
  final String source; // 'ai', 'fallback', o 'cache'
  final DateTime? lastUpdated;
  final bool userAuthenticated;
  final bool hasPreferences; // Si el usuario tiene preferencias del onboarding
  final bool hasHistory; // Si el usuario tiene historial de visualizacion

  const AIPicksState({
    this.picks = const [],
    this.isLoading = true, // Iniciar en loading
    this.isRefreshing = false,
    this.error,
    this.source = 'none',
    this.lastUpdated,
    this.userAuthenticated = false,
    this.hasPreferences = false,
    this.hasHistory = false,
  });

  AIPicksState copyWith({
    List<AIPick>? picks,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? source,
    DateTime? lastUpdated,
    bool? userAuthenticated,
    bool? hasPreferences,
    bool? hasHistory,
  }) {
    return AIPicksState(
      picks: picks ?? this.picks,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userAuthenticated: userAuthenticated ?? this.userAuthenticated,
      hasPreferences: hasPreferences ?? this.hasPreferences,
      hasHistory: hasHistory ?? this.hasHistory,
    );
  }

  bool get hasAIPicks => picks.isNotEmpty && source == 'ai';
  bool get hasFallback => picks.isNotEmpty && source == 'fallback';
  bool get fromCache => source == 'cache';

  /// Determina el tipo de personalizacion para mostrar en la UI
  /// - 'preferences': Basado en tus gustos y mood
  /// - 'history': Basado en tu historial
  /// - 'trending': Contenido popular (cold start)
  String get personalizationType {
    if (source == 'fallback') return 'trending';
    if (hasPreferences) return 'preferences';
    if (hasHistory) return 'history';
    return 'trending';
  }
}

/// Notifier para los AI Picks con cache local para render instantáneo
class AIPicksNotifier extends StateNotifier<AIPicksState> {
  final SupabaseClient _client;
  final CacheService _cache;
  final String language;
  final String region;

  AIPicksNotifier(
    this._client,
    this._cache, {
    this.language = 'es-ES',
    this.region = 'ES',
  }) : super(const AIPicksState());

  /// Genera la cache key - simplificado para evitar problemas de sincronización
  /// Solo usa userId (las preferencias regionales cambian durante init y causaban cache miss)
  /// El contenido se actualizará en background con el idioma correcto
  String _getCacheKey() {
    final userId = _client.auth.currentUser?.id ?? 'anonymous';
    // NO incluir language/region porque cambian durante la inicialización
    // y causan que la segunda instancia del provider busque una key diferente
    return 'ai_picks_v2_$userId';
  }

  /// Carga los picks de IA con estrategia cache-first
  /// 1. Render inmediato desde cache local (si existe)
  /// 2. Fetch async del servidor
  /// 3. Actualizar UI y guardar en cache
  Future<void> loadPicks({int pickCount = 5}) async {
    if (!mounted) return;

    final cacheKey = _getCacheKey();

    // PASO 1: Intentar cargar desde cache local para render instantáneo
    final cachedData = _cache.get<Map<String, dynamic>>(cacheKey);

    if (cachedData != null) {
      try {
        final cachedPicks = _parsePicksFromCache(cachedData);
        if (cachedPicks.isNotEmpty) {
          state = state.copyWith(
            picks: cachedPicks,
            isLoading: false,
            isRefreshing: true,
            source: 'cache',
            lastUpdated: DateTime.now(),
          );
        }
      } catch (_) {}
    }

    // Si ya hay datos recientes en memoria (menos de 5 min), no refrescar
    if (state.picks.isNotEmpty &&
        state.lastUpdated != null &&
        state.source != 'cache') {
      final elapsed = DateTime.now().difference(state.lastUpdated!);
      if (elapsed.inMinutes < 5) {
        state = state.copyWith(isRefreshing: false);
        return;
      }
    }

    // Si no hay datos en cache, mostrar loading
    if (state.picks.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    // ══════════════════════════════════════════════════════════════════
    // PASO 2: Fetch del servidor (async)
    // ══════════════════════════════════════════════════════════════════
    try {
      final response = await _client.callAiHomePicks(
        pickCount: pickCount,
        language: language,
        region: region,
      );

      if (!mounted) return;

      if (response == null) {
        throw Exception('Respuesta vacia del servidor');
      }

      final data = response as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Error desconocido');
      }

      final picksList = data['picks'] as List<dynamic>? ?? [];
      final picks = picksList
          .map((json) => AIPick.fromJson(json as Map<String, dynamic>))
          .toList();

      final source = data['source'] as String? ?? 'unknown';

      // Parse meta fields
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      final userAuthenticated = meta['user_authenticated'] as bool? ?? false;
      final hasPreferences = meta['has_preferences'] as bool? ?? false;
      final hasHistory = meta['has_history'] as bool? ?? false;

      // PASO 3: Actualizar UI y guardar en cache local
      state = state.copyWith(
        picks: picks,
        isLoading: false,
        isRefreshing: false,
        source: source,
        lastUpdated: DateTime.now(),
        userAuthenticated: userAuthenticated,
        hasPreferences: hasPreferences,
        hasHistory: hasHistory,
      );

      await _saveToCache(cacheKey, picks, meta);

    } on FunctionException catch (e) {
      if (!mounted) return;
      if (state.picks.isNotEmpty) {
        state = state.copyWith(isRefreshing: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.reasonPhrase ?? 'Error en Edge Function',
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Si hay datos cacheados, mantenerlos
      if (state.picks.isNotEmpty) {
        state = state.copyWith(isRefreshing: false);
      } else {
        // Intentar cache stale como último recurso
        final staleData = _cache.getStale<Map<String, dynamic>>(cacheKey);
        if (staleData != null) {
          try {
            final stalePicks = _parsePicksFromCache(staleData);
            if (stalePicks.isNotEmpty) {
              state = state.copyWith(
                picks: stalePicks,
                isLoading: false,
                isRefreshing: false,
                source: 'cache',
              );
              return;
            }
          } catch (_) {}
        }

        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Parsea picks desde datos cacheados
  List<AIPick> _parsePicksFromCache(Map<String, dynamic> data) {
    final picksList = data['picks'] as List<dynamic>? ?? [];
    return picksList
        .map((json) => AIPick.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Guarda picks en cache local
  Future<void> _saveToCache(
    String key,
    List<AIPick> picks,
    Map<String, dynamic> meta,
  ) async {
    try {
      await _cache.put(
        key,
        {
          'picks': picks.map((p) => p.toJson()).toList(),
          'meta': meta,
          'cached_at': DateTime.now().toIso8601String(),
        },
        ttlMinutes: CacheService.ttlAiPicks,
        flush: true,
      );
    } catch (_) {}
  }

  /// Refresca los picks (fuerza recarga ignorando cache)
  /// Rate limit: solo permite refresh cada 2 minutos para controlar costos
  /// Retorna true si se hizo refresh, false si fue rate limited
  Future<bool> refresh({int pickCount = 5}) async {
    if (!mounted) return false;

    // Rate limit: si hay picks recientes (menos de 2 min), no refrescar
    if (state.picks.isNotEmpty && state.lastUpdated != null) {
      final elapsed = DateTime.now().difference(state.lastUpdated!);
      if (elapsed.inMinutes < 2) {
        // Mostrar brevemente el indicador y terminar
        state = state.copyWith(isRefreshing: true);
        await Future.delayed(const Duration(milliseconds: 300));
        state = state.copyWith(isRefreshing: false);
        return false; // Rate limited
      }
    }

    // Mostrar loading
    state = state.copyWith(isRefreshing: true);

    // Invalidar cache actual
    final cacheKey = _getCacheKey();
    await _cache.delete(cacheKey);

    // Fetch directo al servidor (bypass loadPicks para evitar cache logic)
    try {
      final response = await _client.callAiHomePicks(
        pickCount: pickCount,
        language: language,
        region: region,
      );

      if (!mounted) return false;

      if (response == null) {
        throw Exception('Respuesta vacia del servidor');
      }

      final data = response as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Error desconocido');
      }

      final picksList = data['picks'] as List<dynamic>? ?? [];
      final picks = picksList
          .map((json) => AIPick.fromJson(json as Map<String, dynamic>))
          .toList();

      final source = data['source'] as String? ?? 'unknown';

      // Parse meta fields
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      final userAuthenticated = meta['user_authenticated'] as bool? ?? false;
      final hasPreferences = meta['has_preferences'] as bool? ?? false;
      final hasHistory = meta['has_history'] as bool? ?? false;

      // Actualizar estado con picks frescos
      state = state.copyWith(
        picks: picks,
        isLoading: false,
        isRefreshing: false,
        source: source,
        lastUpdated: DateTime.now(),
        userAuthenticated: userAuthenticated,
        hasPreferences: hasPreferences,
        hasHistory: hasHistory,
      );

      // Guardar en cache
      await _saveToCache(cacheKey, picks, meta);

      return true; // Refresh exitoso

    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

/// Provider de AI Picks con cache local
/// Usa ref.read para evitar rebuilds cuando cambian dependencias durante init
final aiPicksProvider =
    StateNotifierProvider<AIPicksNotifier, AIPicksState>((ref) {
  final client = ref.read(supabaseClientProvider);
  final cache = ref.read(cacheServiceProvider);
  final regionalPrefs = ref.read(regionalPrefsProvider);
  return AIPicksNotifier(
    client,
    cache,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});

/// Provider para verificar si el usuario tiene historial (para personalizar UI)
final hasUserHistoryProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;

  if (user == null) return false;

  try {
    final response = await client
        .from('user_movie_state')
        .select('id')
        .eq('user_id', user.id)
        .limit(1);

    return (response as List).isNotEmpty;
  } catch (_) {
    return false;
  }
});

/// Estado de las preferencias del usuario
class UserPreferencesState {
  final List<int> preferredGenres;
  final String moodText;
  final bool onboardingCompleted;
  final bool isLoading;
  final String? error;

  const UserPreferencesState({
    this.preferredGenres = const [],
    this.moodText = '',
    this.onboardingCompleted = false,
    this.isLoading = false,
    this.error,
  });

  UserPreferencesState copyWith({
    List<int>? preferredGenres,
    String? moodText,
    bool? onboardingCompleted,
    bool? isLoading,
    String? error,
  }) {
    return UserPreferencesState(
      preferredGenres: preferredGenres ?? this.preferredGenres,
      moodText: moodText ?? this.moodText,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasPreferences => preferredGenres.isNotEmpty || moodText.isNotEmpty;
}

/// Notifier para las preferencias del usuario
class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final SupabaseClient _client;

  UserPreferencesNotifier(this._client) : super(const UserPreferencesState());

  /// Carga las preferencias del usuario desde profiles
  Future<void> loadPreferences() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(onboardingCompleted: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _client
          .from('profiles')
          .select('preferred_genres, mood_text, onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          onboardingCompleted: false,
        );
        return;
      }

      state = state.copyWith(
        preferredGenres: response['preferred_genres'] != null
            ? List<int>.from(response['preferred_genres'])
            : [],
        moodText: response['mood_text'] ?? '',
        onboardingCompleted: response['onboarding_completed'] ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Fuerza recarga de preferencias
  Future<void> refresh() async {
    await loadPreferences();
  }
}

/// Provider de preferencias del usuario
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserPreferencesNotifier(client);
});
