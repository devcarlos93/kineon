import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';
import '../../data/repositories/media_repository_impl.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FILTROS
// ═══════════════════════════════════════════════════════════════════════════

/// Géneros de películas de TMDB
class Genre {
  final int id;
  final String name;
  const Genre(this.id, this.name);
}

const movieGenres = [
  Genre(28, 'Acción'),
  Genre(12, 'Aventura'),
  Genre(16, 'Animación'),
  Genre(35, 'Comedia'),
  Genre(80, 'Crimen'),
  Genre(99, 'Documental'),
  Genre(18, 'Drama'),
  Genre(10751, 'Familia'),
  Genre(14, 'Fantasía'),
  Genre(36, 'Historia'),
  Genre(27, 'Terror'),
  Genre(10402, 'Música'),
  Genre(9648, 'Misterio'),
  Genre(10749, 'Romance'),
  Genre(878, 'Ciencia Ficción'),
  Genre(53, 'Suspenso'),
  Genre(10752, 'Bélica'),
  Genre(37, 'Western'),
];

const tvGenres = [
  Genre(10759, 'Acción y Aventura'),
  Genre(16, 'Animación'),
  Genre(35, 'Comedia'),
  Genre(80, 'Crimen'),
  Genre(99, 'Documental'),
  Genre(18, 'Drama'),
  Genre(10751, 'Familia'),
  Genre(10762, 'Niños'),
  Genre(9648, 'Misterio'),
  Genre(10763, 'Noticias'),
  Genre(10764, 'Reality'),
  Genre(10765, 'Sci-Fi y Fantasía'),
  Genre(10766, 'Telenovela'),
  Genre(10767, 'Talk Show'),
  Genre(10768, 'Política'),
  Genre(37, 'Western'),
];

/// Opciones de ordenamiento
enum SortOption {
  popularityDesc('popularity.desc', 'Más populares'),
  popularityAsc('popularity.asc', 'Menos populares'),
  voteAverageDesc('vote_average.desc', 'Mejor valoradas'),
  releaseDateDesc('primary_release_date.desc', 'Más recientes'),
  releaseDateAsc('primary_release_date.asc', 'Más antiguas');

  final String value;
  final String label;
  const SortOption(this.value, this.label);
}

/// Estado de filtros
class MediaFilters {
  final int? genreId;
  final int? year;
  final SortOption sortBy;
  final double? minRating;

  const MediaFilters({
    this.genreId,
    this.year,
    this.sortBy = SortOption.popularityDesc,
    this.minRating,
  });

  MediaFilters copyWith({
    int? genreId,
    int? year,
    SortOption? sortBy,
    double? minRating,
    bool clearGenre = false,
    bool clearYear = false,
    bool clearRating = false,
  }) {
    return MediaFilters(
      genreId: clearGenre ? null : (genreId ?? this.genreId),
      year: clearYear ? null : (year ?? this.year),
      sortBy: sortBy ?? this.sortBy,
      minRating: clearRating ? null : (minRating ?? this.minRating),
    );
  }

  bool get hasFilters => genreId != null || year != null || minRating != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFilters &&
          genreId == other.genreId &&
          year == other.year &&
          sortBy == other.sortBy &&
          minRating == other.minRating;

  @override
  int get hashCode => Object.hash(genreId, year, sortBy, minRating);
}

/// Tipos de lista disponibles
enum MediaListType {
  trendingMovies('trending_movies'),
  trendingTv('trending_tv'),
  popular('popular'),
  topRated('top_rated'),
  upcoming('upcoming'),
  nowPlaying('now_playing');

  final String value;
  const MediaListType(this.value);

  static MediaListType fromString(String value) {
    return MediaListType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaListType.trendingMovies,
    );
  }

  /// Obtiene el titulo localizado
  String getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case MediaListType.trendingMovies:
        return l10n.listTrendingMovies;
      case MediaListType.trendingTv:
        return l10n.listTrendingTv;
      case MediaListType.popular:
        return l10n.listPopular;
      case MediaListType.topRated:
        return l10n.listTopRated;
      case MediaListType.upcoming:
        return l10n.listUpcoming;
      case MediaListType.nowPlaying:
        return l10n.listNowPlaying;
    }
  }
}

/// Provider para la lista de medios paginada
final mediaListProvider = StateNotifierProvider.family<MediaListNotifier, MediaListState, MediaListType>(
  (ref, type) => MediaListNotifier(
    ref.watch(mediaRepositoryProvider),
    ref.watch(supabaseClientProvider),
    ref.watch(regionalPrefsProvider),
    type,
  ),
);

/// Estado de la lista
class MediaListState {
  final List<MediaItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final MediaFilters filters;

  const MediaListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.filters = const MediaFilters(),
  });

  MediaListState copyWith({
    List<MediaItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    MediaFilters? filters,
  }) {
    return MediaListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      filters: filters ?? this.filters,
    );
  }

  bool get hasMore => currentPage < totalPages;
}

/// Notifier para la lista
class MediaListNotifier extends StateNotifier<MediaListState> {
  final MediaRepository _repository;
  final SupabaseClient _client;
  final RegionalPrefs _regionalPrefs;
  final MediaListType _type;

  MediaListNotifier(
    this._repository,
    this._client,
    this._regionalPrefs,
    this._type,
  ) : super(const MediaListState());

  Future<void> loadInitial() async {
    if (state.items.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _fetchPage(1);
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (response) => state = state.copyWith(
          items: response.items,
          isLoading: false,
          currentPage: response.page,
          totalPages: response.totalPages,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _fetchPage(nextPage);
      result.fold(
        (failure) => state = state.copyWith(isLoadingMore: false),
        (response) => state = state.copyWith(
          items: [...state.items, ...response.items],
          isLoadingMore: false,
          currentPage: response.page,
          totalPages: response.totalPages,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Aplica filtros y recarga la lista
  Future<void> applyFilters(MediaFilters filters) async {
    state = MediaListState(filters: filters, isLoading: true);

    try {
      final result = await _fetchPage(1);
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (response) => state = state.copyWith(
          items: response.items,
          isLoading: false,
          currentPage: response.page,
          totalPages: response.totalPages,
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Limpia todos los filtros
  Future<void> clearFilters() async {
    await applyFilters(const MediaFilters());
  }

  Future<Either<Failure, PaginatedResult<MediaItem>>> _fetchPage(int page) async {
    final filters = state.filters;

    // Si hay filtros activos o sorting diferente, usar discover
    if (filters.hasFilters || filters.sortBy != SortOption.popularityDesc) {
      return _fetchWithDiscover(page, filters);
    }

    // Sin filtros, usar endpoints originales
    switch (_type) {
      case MediaListType.trendingMovies:
        return _repository.getTrendingMovies(page: page);
      case MediaListType.trendingTv:
        return _repository.getTrendingTv(page: page);
      case MediaListType.popular:
        return _repository.getPopularMovies(page: page);
      case MediaListType.topRated:
        return _repository.getTopRatedMovies(page: page);
      case MediaListType.upcoming:
        return _repository.getUpcomingMovies(page: page);
      case MediaListType.nowPlaying:
        return _repository.getNowPlayingMovies(page: page);
    }
  }

  /// Fetch usando el endpoint discover con filtros
  Future<Either<Failure, PaginatedResult<MediaItem>>> _fetchWithDiscover(
    int page,
    MediaFilters filters,
  ) async {
    try {
      final isMovie = _type != MediaListType.trendingTv;
      final contentType = isMovie ? 'movie' : 'tv';

      final queryParams = <String, dynamic>{
        'page': page,
        'sort_by': filters.sortBy.value,
        'include_adult': false,
        'include_video': false,
      };

      if (filters.genreId != null) {
        queryParams['with_genres'] = filters.genreId.toString();
      }

      if (filters.year != null) {
        if (isMovie) {
          queryParams['primary_release_year'] = filters.year;
        } else {
          queryParams['first_air_date_year'] = filters.year;
        }
      }

      if (filters.minRating != null) {
        queryParams['vote_average.gte'] = filters.minRating;
        queryParams['vote_count.gte'] = 50; // Mínimo de votos para relevancia
      }

      final response = await _client.functions.invoke(
        'tmdb-proxy',
        body: {
          'path': 'discover/$contentType',
          'query': queryParams,
          'language': _regionalPrefs.tmdbLanguage,
          'region': _regionalPrefs.tmdbRegion,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(ServerFailure(message: 'No se recibieron datos'));
      }

      final results = (data['results'] as List<dynamic>?) ?? [];
      final items = results.map((json) {
        final map = json as Map<String, dynamic>;
        return MediaItem(
          id: map['id'] as int,
          title: (map['title'] ?? map['name'] ?? '') as String,
          originalTitle: (map['original_title'] ?? map['original_name']) as String?,
          overview: map['overview'] as String?,
          posterPath: map['poster_path'] as String?,
          backdropPath: map['backdrop_path'] as String?,
          voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
          voteCount: map['vote_count'] as int? ?? 0,
          popularity: (map['popularity'] as num?)?.toDouble() ?? 0,
          releaseDate: (map['release_date'] ?? map['first_air_date']) as String?,
          genreIds: (map['genre_ids'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              [],
          contentType: isMovie ? ContentType.movie : ContentType.tv,
        );
      }).toList();

      return Right(PaginatedResult(
        items: items,
        page: data['page'] as int? ?? 1,
        totalPages: data['total_pages'] as int? ?? 1,
        totalResults: data['total_results'] as int? ?? 0,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    final currentFilters = state.filters;
    state = MediaListState(filters: currentFilters);
    await loadInitial();
  }
}

/// Pantalla de lista de medios
class MediaListScreen extends ConsumerStatefulWidget {
  final MediaListType listType;

  const MediaListScreen({
    super.key,
    required this.listType,
  });

  @override
  ConsumerState<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends ConsumerState<MediaListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(mediaListProvider(widget.listType).notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(mediaListProvider(widget.listType).notifier).loadMore();
    }
  }

  void _onItemTap(MediaItem item) {
    final type = item.contentType == ContentType.movie ? 'movie' : 'tv';
    context.push('/details/$type/${item.id}');
  }

  bool get _isMovieList => widget.listType != MediaListType.trendingTv;

  void _showGenreFilter(MediaFilters currentFilters) {
    final genres = _isMovieList ? movieGenres : tvGenres;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Género',
        children: [
          _FilterOption(
            label: 'Todos',
            isSelected: currentFilters.genreId == null,
            onTap: () {
              Navigator.pop(context);
              ref.read(mediaListProvider(widget.listType).notifier)
                  .applyFilters(currentFilters.copyWith(clearGenre: true));
            },
          ),
          ...genres.map((g) => _FilterOption(
            label: g.name,
            isSelected: currentFilters.genreId == g.id,
            onTap: () {
              Navigator.pop(context);
              ref.read(mediaListProvider(widget.listType).notifier)
                  .applyFilters(currentFilters.copyWith(genreId: g.id));
            },
          )),
        ],
      ),
    );
  }

  void _showYearFilter(MediaFilters currentFilters) {
    final currentYear = DateTime.now().year;
    final years = List.generate(50, (i) => currentYear - i);
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Año',
        children: [
          _FilterOption(
            label: 'Todos',
            isSelected: currentFilters.year == null,
            onTap: () {
              Navigator.pop(context);
              ref.read(mediaListProvider(widget.listType).notifier)
                  .applyFilters(currentFilters.copyWith(clearYear: true));
            },
          ),
          ...years.map((y) => _FilterOption(
            label: y.toString(),
            isSelected: currentFilters.year == y,
            onTap: () {
              Navigator.pop(context);
              ref.read(mediaListProvider(widget.listType).notifier)
                  .applyFilters(currentFilters.copyWith(year: y));
            },
          )),
        ],
      ),
    );
  }

  void _showSortFilter(MediaFilters currentFilters) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Ordenar por',
        children: SortOption.values.map((s) => _FilterOption(
          label: s.label,
          isSelected: currentFilters.sortBy == s,
          onTap: () {
            Navigator.pop(context);
            ref.read(mediaListProvider(widget.listType).notifier)
                .applyFilters(currentFilters.copyWith(sortBy: s));
          },
        )).toList(),
      ),
    );
  }

  String? _getGenreName(int? genreId) {
    if (genreId == null) return null;
    final genres = _isMovieList ? movieGenres : tvGenres;
    try {
      return genres.firstWhere((g) => g.id == genreId).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaListProvider(widget.listType));
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final filters = state.filters;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header con estilo premium
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button y subtitle
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: colors.textPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.listCuratedDiscovery,
                          style: AppTypography.overline.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Titulo principal
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text(
                        widget.listType.getTitle(context),
                        style: AppTypography.h1.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // Género
                  _FilterChip(
                    label: _getGenreName(filters.genreId) ?? 'Género',
                    isActive: filters.genreId != null,
                    onTap: () => _showGenreFilter(filters),
                  ),
                  const SizedBox(width: 10),
                  // Año
                  _FilterChip(
                    label: filters.year?.toString() ?? 'Año',
                    isActive: filters.year != null,
                    onTap: () => _showYearFilter(filters),
                  ),
                  const SizedBox(width: 10),
                  // Ordenar
                  _FilterChip(
                    label: filters.sortBy.label,
                    isActive: filters.sortBy != SortOption.popularityDesc,
                    onTap: () => _showSortFilter(filters),
                  ),
                  // Limpiar filtros
                  if (filters.hasFilters) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        ref.read(mediaListProvider(widget.listType).notifier)
                            .clearFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: colors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Limpiar',
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Content - Grid de 2 columnas
          if (state.isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _SkeletonGridCard(),
                  childCount: 6,
                ),
              ),
            )
          else if (state.error != null && state.items.isEmpty)
            SliverFillRemaining(
              child: _ErrorWidget(
                message: state.error!,
                onRetry: () {
                  ref.read(mediaListProvider(widget.listType).notifier).refresh();
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = state.items[index];
                    return _GridPosterCard(
                      item: item,
                      onTap: () => _onItemTap(item),
                    );
                  },
                  childCount: state.items.length,
                ),
              ),
            ),

          // Loading more indicator
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Card para el grid con rating badge
class _GridPosterCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;

  const _GridPosterCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster con rating badge
          Expanded(
            child: Stack(
              children: [
                // Poster
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: item.posterUrl != null
                        ? Image.network(
                            item.posterUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _PlaceholderPoster(),
                          )
                        : _PlaceholderPoster(),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.ratingFormatted} AI',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textOnAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Titulo
          Text(
            item.title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Genero y año
          Text(
            _getSubtitle(item),
            style: AppTypography.bodySmall.copyWith(
              color: colors.accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getSubtitle(MediaItem item) {
    final genre = _getGenreName(item.genreIds.isNotEmpty ? item.genreIds.first : null);
    final year = item.releaseYear;
    if (genre != null && year != null) {
      return '$genre • $year';
    } else if (year != null) {
      return '$year';
    } else if (genre != null) {
      return genre;
    }
    return '';
  }

  String? _getGenreName(int? genreId) {
    if (genreId == null) return null;
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
      // TV
      10759: 'Action',
      10762: 'Kids',
      10763: 'News',
      10764: 'Reality',
      10765: 'Sci-Fi',
      10766: 'Soap',
      10767: 'Talk',
      10768: 'Politics',
    };
    return genreMap[genreId];
  }
}

/// Placeholder para poster
class _PlaceholderPoster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surfaceElevated,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: colors.textTertiary,
          size: 40,
        ),
      ),
    );
  }
}

/// Skeleton para el grid
class _SkeletonGridCard extends StatelessWidget {
  const _SkeletonGridCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: 80,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Widget de error
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Reintentar',
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.textOnAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS DE FILTROS
// ═══════════════════════════════════════════════════════════════════════════

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? colors.accent.withValues(alpha: 0.4)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? colors.accent : colors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isActive ? colors.accent : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet de filtros
class _FilterSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSheet({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title,
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // Options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opción de filtro
class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected ? colors.accent : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: colors.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
