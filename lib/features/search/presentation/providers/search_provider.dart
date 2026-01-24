import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/repositories/media_repository_impl.dart';
import '../../../home/domain/entities/media_item.dart';
import '../../../home/domain/entities/movie_details.dart';
import '../../../home/domain/repositories/media_repository.dart';

/// Tipo de búsqueda
enum SearchType { all, movie, tv }

/// Estado de búsqueda
class SearchState {
  final String query;
  final SearchType searchType;
  final List<MediaItem> results;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const SearchState({
    this.query = '',
    this.searchType = SearchType.all,
    this.results = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.error,
  });

  SearchState copyWith({
    String? query,
    SearchType? searchType,
    List<MediaItem>? results,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// Notifier de búsqueda
class SearchNotifier extends StateNotifier<SearchState> {
  final MediaRepository _repository;
  Timer? _debounceTimer;

  SearchNotifier(this._repository) : super(const SearchState());

  /// Busca con debounce
  void search(String query) {
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  /// Cambia el tipo de búsqueda
  void setSearchType(SearchType type) {
    if (type == state.searchType) return;
    state = state.copyWith(searchType: type, results: [], currentPage: 1);
    if (state.query.isNotEmpty) {
      _performSearch(state.query);
    }
  }

  /// Realiza la búsqueda
  Future<void> _performSearch(String query, {bool loadMore = false}) async {
    if (!loadMore) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final page = loadMore ? state.currentPage + 1 : 1;

    final result = switch (state.searchType) {
      SearchType.all => await _repository.searchMulti(query, page: page),
      SearchType.movie => await _repository.searchMovies(query, page: page),
      SearchType.tv => await _repository.searchTv(query, page: page),
    };

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (paginatedResult) {
        final newResults = loadMore 
            ? [...state.results, ...paginatedResult.items]
            : paginatedResult.items;
        
        state = state.copyWith(
          results: newResults,
          isLoading: false,
          hasMore: paginatedResult.hasMore,
          currentPage: paginatedResult.page,
        );
      },
    );
  }

  /// Carga más resultados
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await _performSearch(state.query, loadMore: true);
  }

  /// Limpia la búsqueda
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider de búsqueda
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  return SearchNotifier(repository);
});

/// Provider para géneros de películas
final movieGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final result = await repository.getMovieGenres();
  return result.fold((l) => [], (r) => r);
});

/// Provider para géneros de series
final tvGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final result = await repository.getTvGenres();
  return result.fold((l) => [], (r) => r);
});
