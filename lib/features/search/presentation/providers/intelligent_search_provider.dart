import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../home/data/repositories/media_repository_impl.dart';
import '../../../home/domain/entities/media_item.dart';
import '../../../home/domain/repositories/media_repository.dart';
import '../../../subscription/subscription.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELOS
// ═══════════════════════════════════════════════════════════════════════════

/// Plan de búsqueda generado por IA
class SearchPlan {
  final String intentSummary;
  final String mediaType;
  final DiscoverFilters discover;
  final List<String> tags;
  final SearchPlanUI ui;
  final double confidence;

  const SearchPlan({
    required this.intentSummary,
    required this.mediaType,
    required this.discover,
    required this.tags,
    required this.ui,
    required this.confidence,
  });

  factory SearchPlan.fromJson(Map<String, dynamic> json) {
    return SearchPlan(
      intentSummary: json['intent_summary'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'movie',
      discover: DiscoverFilters.fromJson(json['discover'] as Map<String, dynamic>? ?? {}),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      ui: SearchPlanUI.fromJson(json['ui'] as Map<String, dynamic>? ?? {}),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }

  /// Match score como porcentaje (basado en confidence)
  int get matchPercent => (confidence * 100).round();
}

/// Filtros para TMDB discover
class DiscoverFilters {
  final List<int> withGenres;
  final List<int> withoutGenres;
  final double voteAverageGte;
  final int voteCountGte;
  final int? withRuntimeGte;
  final int? withRuntimeLte;
  final String? primaryReleaseDateGte;
  final String? primaryReleaseDateLte;
  final String sortBy;
  final List<int> withWatchProviders;

  const DiscoverFilters({
    this.withGenres = const [],
    this.withoutGenres = const [],
    this.voteAverageGte = 6.0,
    this.voteCountGte = 100,
    this.withRuntimeGte,
    this.withRuntimeLte,
    this.primaryReleaseDateGte,
    this.primaryReleaseDateLte,
    this.sortBy = 'popularity.desc',
    this.withWatchProviders = const [],
  });

  factory DiscoverFilters.fromJson(Map<String, dynamic> json) {
    return DiscoverFilters(
      withGenres: (json['with_genres'] as List<dynamic>?)?.cast<int>() ?? [],
      withoutGenres: (json['without_genres'] as List<dynamic>?)?.cast<int>() ?? [],
      voteAverageGte: (json['vote_average_gte'] as num?)?.toDouble() ?? 6.0,
      voteCountGte: (json['vote_count_gte'] as num?)?.toInt() ?? 100,
      withRuntimeGte: json['with_runtime_gte'] as int?,
      withRuntimeLte: json['with_runtime_lte'] as int?,
      primaryReleaseDateGte: json['primary_release_date_gte'] as String?,
      primaryReleaseDateLte: json['primary_release_date_lte'] as String?,
      sortBy: json['sort_by'] as String? ?? 'popularity.desc',
      withWatchProviders: (json['with_watch_providers'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  /// Convierte a query params para TMDB discover
  Map<String, dynamic> toQueryParams() {
    return {
      if (withGenres.isNotEmpty) 'with_genres': withGenres.join(','),
      if (withoutGenres.isNotEmpty) 'without_genres': withoutGenres.join(','),
      'vote_average.gte': voteAverageGte,
      'vote_count.gte': voteCountGte,
      if (withRuntimeGte != null) 'with_runtime.gte': withRuntimeGte,
      if (withRuntimeLte != null) 'with_runtime.lte': withRuntimeLte,
      if (primaryReleaseDateGte != null) 'primary_release_date.gte': primaryReleaseDateGte,
      if (primaryReleaseDateLte != null) 'primary_release_date.lte': primaryReleaseDateLte,
      'sort_by': sortBy,
      if (withWatchProviders.isNotEmpty) 'with_watch_providers': withWatchProviders.join('|'),
    };
  }
}

/// Labels para UI
class SearchPlanUI {
  final String? moodLabel;
  final String? runtimeLabel;
  final String? yearLabel;
  final String genreLabel;

  const SearchPlanUI({
    this.moodLabel,
    this.runtimeLabel,
    this.yearLabel,
    this.genreLabel = 'Todos',
  });

  factory SearchPlanUI.fromJson(Map<String, dynamic> json) {
    return SearchPlanUI(
      moodLabel: json['mood_label'] as String?,
      runtimeLabel: json['runtime_label'] as String?,
      yearLabel: json['year_label'] as String?,
      genreLabel: json['genre_label'] as String? ?? 'Todos',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════════════

/// Estado de búsqueda inteligente
class IntelligentSearchState {
  final String query;
  final String mediaType; // 'movie' o 'tv'
  final SearchPlan? plan;
  final List<MediaItem> results;
  final bool isLoadingPlan;
  final bool isLoadingResults;
  final String? error;
  final bool limitReached; // True cuando el usuario alcanzó el límite diario

  // Filtros manuales (override del plan)
  final List<int>? selectedGenreIds;
  final String? selectedMood;
  final String? selectedRuntime;
  final String? selectedYear;
  final List<int>? selectedWatchProviders;

  const IntelligentSearchState({
    this.query = '',
    this.mediaType = 'movie',
    this.plan,
    this.results = const [],
    this.isLoadingPlan = false,
    this.isLoadingResults = false,
    this.error,
    this.limitReached = false,
    this.selectedGenreIds,
    this.selectedMood,
    this.selectedRuntime,
    this.selectedYear,
    this.selectedWatchProviders,
  });

  bool get isLoading => isLoadingPlan || isLoadingResults;
  bool get hasResults => results.isNotEmpty;
  bool get hasPlan => plan != null;
  bool get hasAnyFilter =>
      (selectedGenreIds != null && selectedGenreIds!.isNotEmpty) ||
      selectedMood != null ||
      selectedRuntime != null ||
      selectedYear != null ||
      (selectedWatchProviders != null && selectedWatchProviders!.isNotEmpty);

  IntelligentSearchState copyWith({
    String? query,
    String? mediaType,
    SearchPlan? plan,
    List<MediaItem>? results,
    bool? isLoadingPlan,
    bool? isLoadingResults,
    String? error,
    bool? limitReached,
    List<int>? selectedGenreIds,
    String? selectedMood,
    String? selectedRuntime,
    String? selectedYear,
    List<int>? selectedWatchProviders,
    bool clearPlan = false,
    bool clearFilters = false,
    bool clearGenre = false,
    bool clearMood = false,
    bool clearRuntime = false,
    bool clearYear = false,
    bool clearWatchProviders = false,
  }) {
    return IntelligentSearchState(
      query: query ?? this.query,
      mediaType: mediaType ?? this.mediaType,
      plan: clearPlan ? null : (plan ?? this.plan),
      results: results ?? this.results,
      isLoadingPlan: isLoadingPlan ?? this.isLoadingPlan,
      isLoadingResults: isLoadingResults ?? this.isLoadingResults,
      error: error,
      limitReached: limitReached ?? this.limitReached,
      selectedGenreIds: (clearFilters || clearGenre) ? null : (selectedGenreIds ?? this.selectedGenreIds),
      selectedMood: (clearFilters || clearMood) ? null : (selectedMood ?? this.selectedMood),
      selectedRuntime: (clearFilters || clearRuntime) ? null : (selectedRuntime ?? this.selectedRuntime),
      selectedYear: (clearFilters || clearYear) ? null : (selectedYear ?? this.selectedYear),
      selectedWatchProviders: (clearFilters || clearWatchProviders) ? null : (selectedWatchProviders ?? this.selectedWatchProviders),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

class IntelligentSearchNotifier extends StateNotifier<IntelligentSearchState> {
  final SupabaseClient _client;
  final MediaRepository _repository;
  final Ref _ref;
  final String _language;
  final String _region;
  Timer? _debounceTimer;

  // Para evitar contar múltiples usos por sesión de búsqueda
  String? _lastCountedQuery;
  DateTime? _lastUsageTime;

  IntelligentSearchNotifier(
    this._client,
    this._repository,
    this._ref, {
    required String language,
    required String region,
  })  : _language = language,
        _region = region,
        super(const IntelligentSearchState());

  /// Busca con debounce (350ms)
  void search(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const IntelligentSearchState();
      return;
    }

    state = state.copyWith(query: query, isLoadingPlan: true, clearPlan: true);

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _executeSearch(query);
    });
  }

  /// Verifica si debe contar como un nuevo uso de IA
  /// Solo cuenta si:
  /// - La query es significativamente diferente (no solo agregar/quitar caracteres)
  /// - O han pasado más de 30 segundos desde el último uso
  bool _shouldCountAsNewUsage(String query) {
    final now = DateTime.now();

    // Si nunca se ha contado, contar
    if (_lastCountedQuery == null || _lastUsageTime == null) {
      return true;
    }

    // Si han pasado más de 30 segundos, contar como nuevo
    if (now.difference(_lastUsageTime!).inSeconds > 30) {
      return true;
    }

    // Si la query es muy diferente (más de 50% diferente), contar como nuevo
    final lastQuery = _lastCountedQuery!.toLowerCase();
    final currentQuery = query.toLowerCase();

    // Si una query contiene a la otra, es probable que sea typing incremental
    if (lastQuery.contains(currentQuery) || currentQuery.contains(lastQuery)) {
      return false;
    }

    // Si las queries son muy diferentes, contar como nuevo
    return true;
  }

  /// Ejecuta la búsqueda: IA plan → TMDB discover
  Future<void> _executeSearch(String query) async {
    if (!mounted) return;

    // Verificar si este query debería contar como un nuevo uso
    final shouldCount = _shouldCountAsNewUsage(query);

    // Solo verificar gating si vamos a contar como nuevo uso
    if (shouldCount) {
      final subscription = _ref.read(subscriptionProvider);
      if (!subscription.canUse(AIEndpoints.search)) {
        state = state.copyWith(
          isLoadingPlan: false,
          limitReached: true,
        );
        return;
      }
    }

    try {
      // 1. Obtener plan de IA
      state = state.copyWith(isLoadingPlan: true, error: null, limitReached: false);

      final planData = await _client.callAiSearchPlan(
        query: query,
        mediaType: state.mediaType,
        selectedGenreIds: state.selectedGenreIds,
        moodChip: state.selectedMood,
        language: _language,
        region: _region,
      );

      if (!mounted) return;

      // Registrar uso solo si es una búsqueda "nueva"
      if (shouldCount) {
        _lastCountedQuery = query;
        _lastUsageTime = DateTime.now();
        _ref.read(subscriptionProvider.notifier).recordUsage(AIEndpoints.search);
      }

      final plan = SearchPlan.fromJson(planData);
      state = state.copyWith(
        plan: plan,
        isLoadingPlan: false,
        isLoadingResults: true,
      );

      // 2. Llamar a TMDB discover con los filtros del plan
      await _discoverWithPlan(plan);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingPlan: false,
        isLoadingResults: false,
        error: 'Error al procesar búsqueda: $e',
      );
    }
  }

  /// Ejecuta discover con el plan actual
  Future<void> _discoverWithPlan(SearchPlan plan) async {
    if (!mounted) return;

    try {
      final isMovie = plan.mediaType == 'movie';
      final params = plan.discover.toQueryParams();

      final result = isMovie
          ? await _repository.discoverMoviesWithParams(params)
          : await _repository.discoverTvWithParams(params);

      if (!mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingResults: false,
            error: failure.message,
          );
        },
        (paginatedResult) {
          state = state.copyWith(
            results: paginatedResult.items,
            isLoadingResults: false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingResults: false,
        error: 'Error al buscar contenido: $e',
      );
    }
  }

  /// Cambia entre películas y series
  void setMediaType(String mediaType) {
    if (mediaType == state.mediaType) return;
    state = state.copyWith(
      mediaType: mediaType,
      results: [],
      clearPlan: true,
      clearFilters: true,
    );
    if (state.query.isNotEmpty) {
      _executeSearch(state.query);
    }
  }

  /// Actualiza filtro de género y re-ejecuta
  void setGenreFilter(List<int>? genreIds) {
    state = genreIds != null
        ? state.copyWith(selectedGenreIds: genreIds)
        : state.copyWith(clearGenre: true);
    _applyFilters();
  }

  /// Actualiza filtro de mood y re-ejecuta
  void setMoodFilter(String? mood) {
    state = mood != null
        ? state.copyWith(selectedMood: mood)
        : state.copyWith(clearMood: true);
    // Mood se re-ejecuta con IA si hay query, o discover directo si solo hay filtros
    if (state.query.isNotEmpty) {
      _executeSearch(state.query);
    } else if (state.hasAnyFilter) {
      _discoverWithFiltersOnly();
    }
  }

  /// Actualiza filtro de año y re-ejecuta
  void setYearFilter(String? year) {
    state = year != null
        ? state.copyWith(selectedYear: year)
        : state.copyWith(clearYear: true);
    _applyFilters();
  }

  /// Actualiza filtro de runtime y re-ejecuta
  void setRuntimeFilter(String? runtime) {
    state = runtime != null
        ? state.copyWith(selectedRuntime: runtime)
        : state.copyWith(clearRuntime: true);
    _applyFilters();
  }

  /// Actualiza filtro de plataforma de streaming y re-ejecuta
  void setWatchProviderFilter(List<int>? providerIds) {
    state = providerIds != null
        ? state.copyWith(selectedWatchProviders: providerIds)
        : state.copyWith(clearWatchProviders: true);
    _applyFilters();
  }

  /// Lógica unificada: decide si usar plan + overrides o discover directo
  void _applyFilters() {
    if (state.plan != null) {
      _rediscoverWithOverrides();
    } else if (state.query.isNotEmpty) {
      _executeSearch(state.query);
    } else if (state.hasAnyFilter) {
      _discoverWithFiltersOnly();
    }
  }

  /// Construye los params de filtro del usuario (sin plan de IA)
  Map<String, dynamic> _buildFilterParams() {
    final params = <String, dynamic>{
      'sort_by': 'popularity.desc',
      'vote_count.gte': 50,
    };

    if (state.selectedGenreIds != null && state.selectedGenreIds!.isNotEmpty) {
      params['with_genres'] = state.selectedGenreIds!.join(',');
    }

    if (state.selectedYear != null) {
      final year = state.selectedYear!;
      params['primary_release_date.gte'] = '$year-01-01';
      params['primary_release_date.lte'] = '$year-12-31';
    }

    if (state.selectedRuntime != null) {
      final runtime = int.tryParse(state.selectedRuntime!);
      if (runtime != null) {
        params['with_runtime.lte'] = runtime;
      }
    }

    if (state.selectedWatchProviders != null && state.selectedWatchProviders!.isNotEmpty) {
      params['with_watch_providers'] = state.selectedWatchProviders!.join('|');
      params['watch_region'] = _region;
    }

    return params;
  }

  /// Discover directo con solo los filtros del usuario (sin IA)
  Future<void> _discoverWithFiltersOnly() async {
    if (!mounted) return;

    state = state.copyWith(isLoadingResults: true, error: null);

    try {
      final isMovie = state.mediaType == 'movie';
      final params = _buildFilterParams();

      final result = isMovie
          ? await _repository.discoverMoviesWithParams(params)
          : await _repository.discoverTvWithParams(params);

      if (!mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(isLoadingResults: false, error: failure.message);
        },
        (paginatedResult) {
          state = state.copyWith(
            results: paginatedResult.items,
            isLoadingResults: false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingResults: false,
        error: 'Error: $e',
      );
    }
  }

  /// Re-ejecuta discover con el plan actual + overrides manuales del usuario
  Future<void> _rediscoverWithOverrides() async {
    if (!mounted || state.plan == null) return;

    state = state.copyWith(isLoadingResults: true);

    try {
      final plan = state.plan!;
      final isMovie = plan.mediaType == 'movie';
      final params = plan.discover.toQueryParams();

      // Aplicar overrides del usuario
      if (state.selectedGenreIds != null && state.selectedGenreIds!.isNotEmpty) {
        params['with_genres'] = state.selectedGenreIds!.join(',');
      }
      if (state.selectedYear != null) {
        final year = state.selectedYear!;
        params['primary_release_date.gte'] = '$year-01-01';
        params['primary_release_date.lte'] = '$year-12-31';
      }
      if (state.selectedRuntime != null) {
        final runtime = int.tryParse(state.selectedRuntime!);
        if (runtime != null) {
          params['with_runtime.lte'] = runtime;
        }
      }
      if (state.selectedWatchProviders != null && state.selectedWatchProviders!.isNotEmpty) {
        params['with_watch_providers'] = state.selectedWatchProviders!.join('|');
        params['watch_region'] = _region;
      }

      final result = isMovie
          ? await _repository.discoverMoviesWithParams(params)
          : await _repository.discoverTvWithParams(params);

      if (!mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingResults: false,
            error: failure.message,
          );
        },
        (paginatedResult) {
          state = state.copyWith(
            results: paginatedResult.items,
            isLoadingResults: false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingResults: false,
        error: 'Error al buscar contenido: $e',
      );
    }
  }

  /// Solo actualiza el query sin ejecutar búsqueda (para usuarios free mientras escriben)
  void setQuery(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = const IntelligentSearchState();
      return;
    }

    // Solo actualizar el query, no ejecutar búsqueda
    state = state.copyWith(query: query);
  }

  /// Limpia la búsqueda
  void clear() {
    _debounceTimer?.cancel();
    state = const IntelligentSearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider de búsqueda inteligente
final intelligentSearchProvider =
    StateNotifierProvider<IntelligentSearchNotifier, IntelligentSearchState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final repository = ref.watch(mediaRepositoryProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);

  return IntelligentSearchNotifier(
    client,
    repository,
    ref,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});

/// Sugerencias de búsqueda para mostrar como hint
const searchSuggestions = [
  'Algo como Interstellar pero más corto',
  'Comedia romántica para ver en pareja',
  'Serie de terror psicológico',
  'Película de los 80s de acción',
  'Algo relajante para el domingo',
  'Drama con final feliz',
  'Ciencia ficción con viajes en el tiempo',
  'Thriller de suspenso sin violencia',
];
