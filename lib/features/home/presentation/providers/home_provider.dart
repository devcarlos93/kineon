import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../library/data/repositories/library_repository.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';
import 'ai_picks_provider.dart';

/// Estado del Home
class HomeState {
  final List<MediaItem> trendingMovies;
  final List<MediaItem> trendingTv;
  final List<MediaItem> popularMovies;
  final List<MediaItem> topRatedMovies;
  final List<MediaItem> upcomingMovies;
  final List<MediaItem> nowPlayingMovies;
  final bool isLoading;
  final bool isRefreshing; // True cuando hay datos pero se actualiza en background
  final String? error;
  final DateTime? lastUpdated;

  const HomeState({
    this.trendingMovies = const [],
    this.trendingTv = const [],
    this.popularMovies = const [],
    this.topRatedMovies = const [],
    this.upcomingMovies = const [],
    this.nowPlayingMovies = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  bool get hasData =>
      trendingMovies.isNotEmpty ||
      popularMovies.isNotEmpty ||
      nowPlayingMovies.isNotEmpty;

  HomeState copyWith({
    List<MediaItem>? trendingMovies,
    List<MediaItem>? trendingTv,
    List<MediaItem>? popularMovies,
    List<MediaItem>? topRatedMovies,
    List<MediaItem>? upcomingMovies,
    List<MediaItem>? nowPlayingMovies,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HomeState(
      trendingMovies: trendingMovies ?? this.trendingMovies,
      trendingTv: trendingTv ?? this.trendingTv,
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      nowPlayingMovies: nowPlayingMovies ?? this.nowPlayingMovies,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier del Home con estrategia cache-first para render instantáneo
class HomeNotifier extends StateNotifier<HomeState> {
  final MediaRepository _repository;
  final CacheService _cache;
  final String _lang;

  String get _cacheKey => '${_lang}_home_data_v1';

  HomeNotifier(this._repository, this._cache, {String languageCode = 'es'})
      : _lang = languageCode,
        super(const HomeState()) {
    loadHomeData();
  }

  /// Carga todos los datos del home con estrategia cache-first
  /// 1. Render inmediato desde cache local (si existe)
  /// 2. Fetch async del servidor
  /// 3. Actualizar UI y guardar en cache
  Future<void> loadHomeData() async {
    if (!mounted) return;

    // ══════════════════════════════════════════════════════════════════
    // PASO 1: Intentar cargar desde cache local para render instantáneo
    // ══════════════════════════════════════════════════════════════════
    final cachedData = _cache.get<Map<String, dynamic>>(_cacheKey);

    if (cachedData != null) {
      try {
        final cached = _parseFromCache(cachedData);
        if (cached.hasData) {
          state = cached.copyWith(
            isLoading: false,
            isRefreshing: true,
          );
        }
      } catch (_) {}
    }

    // Si ya hay datos recientes en memoria (menos de 5 min), no refrescar
    if (state.hasData && state.lastUpdated != null) {
      final elapsed = DateTime.now().difference(state.lastUpdated!);
      if (elapsed.inMinutes < 5) {
        state = state.copyWith(isRefreshing: false);
        return;
      }
    }

    // Si no hay datos en cache, mostrar loading
    if (!state.hasData) {
      state = state.copyWith(isLoading: true, error: null);
    }

    // ══════════════════════════════════════════════════════════════════
    // PASO 2: Fetch del servidor (async)
    // ══════════════════════════════════════════════════════════════════
    try {
      final results = await Future.wait([
        _repository.getTrendingMovies(),
        _repository.getTrendingTv(),
        _repository.getPopularMovies(),
        _repository.getTopRatedMovies(),
        _repository.getUpcomingMovies(),
        _repository.getNowPlayingMovies(),
      ]);

      if (!mounted) return;

      final newState = state.copyWith(
        trendingMovies: results[0].fold((l) => state.trendingMovies, (r) => r.items),
        trendingTv: results[1].fold((l) => state.trendingTv, (r) => r.items),
        popularMovies: results[2].fold((l) => state.popularMovies, (r) => r.items),
        topRatedMovies: results[3].fold((l) => state.topRatedMovies, (r) => r.items),
        upcomingMovies: results[4].fold((l) => state.upcomingMovies, (r) => r.items),
        nowPlayingMovies: results[5].fold((l) => state.nowPlayingMovies, (r) => r.items),
        isLoading: false,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );

      state = newState;

      // ══════════════════════════════════════════════════════════════════
      // PASO 3: Guardar en cache local para próximo render instantáneo
      // ══════════════════════════════════════════════════════════════════
      await _saveToCache(newState);

    } catch (e) {
      if (!mounted) return;
      // Si hay datos cacheados, mantenerlos
      if (state.hasData) {
        state = state.copyWith(isRefreshing: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Parsea el estado desde datos cacheados
  HomeState _parseFromCache(Map<String, dynamic> data) {
    return HomeState(
      trendingMovies: _parseMediaList(data['trendingMovies']),
      trendingTv: _parseMediaList(data['trendingTv']),
      popularMovies: _parseMediaList(data['popularMovies']),
      topRatedMovies: _parseMediaList(data['topRatedMovies']),
      upcomingMovies: _parseMediaList(data['upcomingMovies']),
      nowPlayingMovies: _parseMediaList(data['nowPlayingMovies']),
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }

  List<MediaItem> _parseMediaList(dynamic list) {
    if (list == null) return [];
    return (list as List<dynamic>)
        .map((json) => MediaItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Guarda el estado en cache local
  Future<void> _saveToCache(HomeState state) async {
    try {
      await _cache.put(
        _cacheKey,
        {
          'trendingMovies': state.trendingMovies.map((m) => m.toJson()).toList(),
          'trendingTv': state.trendingTv.map((m) => m.toJson()).toList(),
          'popularMovies': state.popularMovies.map((m) => m.toJson()).toList(),
          'topRatedMovies': state.topRatedMovies.map((m) => m.toJson()).toList(),
          'upcomingMovies': state.upcomingMovies.map((m) => m.toJson()).toList(),
          'nowPlayingMovies': state.nowPlayingMovies.map((m) => m.toJson()).toList(),
          'cached_at': DateTime.now().toIso8601String(),
        },
        ttlMinutes: CacheService.ttlTrending,
        flush: true,
      );
    } catch (_) {}
  }

  /// Refresca los datos del home (fuerza recarga)
  Future<void> refresh() async {
    if (!mounted) return;

    // Mostrar indicador de refresh si hay datos, loading si no hay
    if (state.hasData) {
      state = state.copyWith(isRefreshing: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    // Invalidar cache actual
    await _cache.delete(_cacheKey);
    state = state.copyWith(lastUpdated: null);
    await loadHomeData();
  }
}

/// Provider del Home con cache local para render instantáneo
/// Usa ref.watch en mediaRepositoryProvider para recrearse cuando cambia el idioma
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  final cache = ref.read(cacheServiceProvider);
  final lang = ref.watch(regionalPrefsProvider).languageCode;
  return HomeNotifier(repository, cache, languageCode: lang);
});

/// Provider para película/serie destacada (primera de trending)
final featuredMediaProvider = Provider<MediaItem?>((ref) {
  final state = ref.watch(homeProvider);
  if (state.trendingMovies.isNotEmpty) {
    return state.trendingMovies.first;
  }
  return null;
});

/// Provider para obtener estados de todos los items del home
/// Combina estados de películas y series en un solo mapa
final homeMediaStatesProvider = FutureProvider.autoDispose<Map<int, MediaState>>((ref) async {
  final homeState = ref.watch(homeProvider);
  final aiPicksState = ref.watch(aiPicksProvider);

  // Separar AI picks por tipo de contenido
  final aiPickMovieIds = aiPicksState.picks
      .where((p) => p.item.contentType == ContentType.movie)
      .map((p) => p.item.id);
  final aiPickTvIds = aiPicksState.picks
      .where((p) => p.item.contentType == ContentType.tv)
      .map((p) => p.item.id);

  // Recopilar todos los IDs de películas (incluyendo AI picks)
  final movieIds = <int>{
    ...homeState.trendingMovies.map((m) => m.id),
    ...homeState.popularMovies.map((m) => m.id),
    ...homeState.topRatedMovies.map((m) => m.id),
    ...homeState.upcomingMovies.map((m) => m.id),
    ...homeState.nowPlayingMovies.map((m) => m.id),
    ...aiPickMovieIds,
  }.toList();

  // Recopilar todos los IDs de series (incluyendo AI picks)
  final tvIds = <int>{
    ...homeState.trendingTv.map((t) => t.id),
    ...aiPickTvIds,
  }.toList();

  // Obtener estados en paralelo
  final results = await Future.wait([
    if (movieIds.isNotEmpty)
      ref.read(batchMediaStatesProvider(BatchMediaStateParams(
        tmdbIds: movieIds,
        contentType: ContentType.movie,
      )).future)
    else
      Future.value(<int, MediaState>{}),
    if (tvIds.isNotEmpty)
      ref.read(batchMediaStatesProvider(BatchMediaStateParams(
        tmdbIds: tvIds,
        contentType: ContentType.tv,
      )).future)
    else
      Future.value(<int, MediaState>{}),
  ]);

  // Combinar resultados
  return {...results[0], ...results[1]};
});
