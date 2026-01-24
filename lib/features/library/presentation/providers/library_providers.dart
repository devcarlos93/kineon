import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/library_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE LISTAS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para la watchlist completa
final watchlistProvider = FutureProvider.autoDispose<List<MediaState>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getWatchlist();
});

/// Provider para favoritos
final favoritesProvider = FutureProvider.autoDispose<List<MediaState>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getFavorites();
});

/// Provider para vistos
final watchedProvider = FutureProvider.autoDispose<List<MediaState>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getWatched();
});

/// Provider para estadísticas
final libraryStatsProvider = FutureProvider.autoDispose<LibraryStats>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getStats();
});

/// Provider para actividad de visualización (heatmap)
final viewingActivityProvider = FutureProvider.autoDispose<ViewingActivity>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getViewingActivity();
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS PARA ITEM ESPECÍFICO
// ═══════════════════════════════════════════════════════════════════════════

/// Parámetros para consultar estado de un media
class MediaStateParams {
  final int tmdbId;
  final ContentType contentType;

  const MediaStateParams({
    required this.tmdbId,
    required this.contentType,
  });

  @override
  bool operator ==(Object other) =>
      other is MediaStateParams &&
      other.tmdbId == tmdbId &&
      other.contentType == contentType;

  @override
  int get hashCode => Object.hash(tmdbId, contentType);
}

/// Provider para obtener estado de un contenido específico
final mediaStateProvider =
    FutureProvider.autoDispose.family<MediaState?, MediaStateParams>(
  (ref, params) async {
    final repo = ref.watch(libraryRepositoryProvider);
    return repo.getMediaState(params.tmdbId, params.contentType);
  },
);

/// Provider para stream de cambios en un contenido
final mediaStateStreamProvider =
    StreamProvider.autoDispose.family<MediaState?, MediaStateParams>(
  (ref, params) {
    final repo = ref.watch(libraryRepositoryProvider);
    return repo.watchMediaState(params.tmdbId, params.contentType);
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS PARA MÚLTIPLES ITEMS (BATCH)
// ═══════════════════════════════════════════════════════════════════════════

/// Parámetros para consultar múltiples estados
class BatchMediaStateParams {
  final List<int> tmdbIds;
  final ContentType contentType;

  const BatchMediaStateParams({
    required this.tmdbIds,
    required this.contentType,
  });

  @override
  bool operator ==(Object other) =>
      other is BatchMediaStateParams &&
      other.contentType == contentType &&
      _listEquals(other.tmdbIds, tmdbIds);

  @override
  int get hashCode => Object.hash(Object.hashAll(tmdbIds), contentType);

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Provider para obtener estados de múltiples items (para listas/carruseles)
final batchMediaStatesProvider =
    FutureProvider.autoDispose.family<Map<int, MediaState>, BatchMediaStateParams>(
  (ref, params) async {
    final repo = ref.watch(libraryRepositoryProvider);
    return repo.getMediaStates(params.tmdbIds, params.contentType);
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER PARA ACCIONES
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para manejar acciones de la biblioteca
class LibraryActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final LibraryRepository _repository;
  final Ref _ref;

  LibraryActionsNotifier(this._repository, this._ref) : super(const AsyncData(null));

  /// Agrega a watchlist
  Future<bool> addToWatchlist(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.addToWatchlist(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      _ref.read(analyticsServiceProvider).trackEvent(
        AnalyticsEvents.addToWatchlist,
        properties: {'tmdb_id': tmdbId, 'content_type': contentType.name},
      );
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Quita de watchlist
  Future<bool> removeFromWatchlist(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.removeFromWatchlist(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      _ref.read(analyticsServiceProvider).trackEvent(
        AnalyticsEvents.removeFromWatchlist,
        properties: {'tmdb_id': tmdbId, 'content_type': contentType.name},
      );
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Toggle favorito
  Future<bool> toggleFavorite(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      final newState = await _repository.toggleFavorite(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      _ref.read(analyticsServiceProvider).trackEvent(
        newState.isFavorite ? AnalyticsEvents.addToFavorites : AnalyticsEvents.removeFromFavorites,
        properties: {'tmdb_id': tmdbId, 'content_type': contentType.name},
      );
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Marcar como visto
  Future<bool> markAsWatched(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.markAsWatched(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      _ref.read(analyticsServiceProvider).trackEvent(
        AnalyticsEvents.markAsWatched,
        properties: {'tmdb_id': tmdbId, 'content_type': contentType.name},
      );
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Quitar de vistos
  Future<bool> removeFromWatched(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.removeFromWatched(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      _ref.read(analyticsServiceProvider).trackEvent(
        AnalyticsEvents.removeFromWatched,
        properties: {'tmdb_id': tmdbId, 'content_type': contentType.name},
      );
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  /// Eliminar completamente
  Future<bool> delete(int tmdbId, ContentType contentType) async {
    if (!mounted) return false;
    state = const AsyncLoading();
    try {
      await _repository.deleteMediaState(tmdbId, contentType);
      _invalidateProviders(tmdbId, contentType);
      if (!mounted) return true;
      state = const AsyncData(null);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  void _invalidateProviders(int tmdbId, ContentType contentType) {
    // Invalidar providers relacionados para que se refresquen
    _ref.invalidate(watchlistProvider);
    _ref.invalidate(favoritesProvider);
    _ref.invalidate(watchedProvider);
    _ref.invalidate(libraryStatsProvider);
    _ref.invalidate(mediaStateProvider(MediaStateParams(
      tmdbId: tmdbId,
      contentType: contentType,
    )));
    // Invalidar estados del Home para que se actualicen los micro-dots
    _ref.invalidate(homeMediaStatesProvider);
    // Invalidar biblioteca con detalles
    _ref.invalidate(watchlistWithDetailsProvider);
    _ref.invalidate(favoritesWithDetailsProvider);
    _ref.invalidate(watchedWithDetailsProvider);
  }
}

/// Provider para acciones de biblioteca
final libraryActionsProvider =
    StateNotifierProvider<LibraryActionsNotifier, AsyncValue<void>>((ref) {
  return LibraryActionsNotifier(
    ref.watch(libraryRepositoryProvider),
    ref,
  );
});

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS PARA UI
// ═══════════════════════════════════════════════════════════════════════════

/// Extension para acceder rápidamente a estados booleanos
extension MediaStateHelpers on MediaState? {
  bool get isInWatchlist => this?.status == WatchStatus.watchlist;
  bool get isFavorite => this?.isFavorite ?? false;
  bool get isWatched => this?.status == WatchStatus.watched;
  bool get isWatching => this?.status == WatchStatus.watching;
  bool get hasState => this != null;
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS PARA BIBLIOTECA CON DETALLES TMDB
// ═══════════════════════════════════════════════════════════════════════════

/// Item de biblioteca con detalles de TMDB (versión ligera para listas)
class LibraryItemWithDetails {
  final MediaState state;
  final TmdbBulkItem? bulkItem;

  const LibraryItemWithDetails({
    required this.state,
    this.bulkItem,
  });

  int get tmdbId => state.tmdbId;
  ContentType get contentType => state.contentType;
  bool get isFavorite => state.isFavorite;
  bool get isInWatchlist => state.isInWatchlist;
  bool get isWatched => state.isWatched;

  // Getters para compatibilidad con UI
  String? get title => bulkItem?.title;
  String? get posterUrl => bulkItem?.posterUrl;
  int? get releaseYear => bulkItem?.releaseYear;
  double? get voteAverage => bulkItem?.voteAverage;
}

/// Item de TMDB obtenido via bulk endpoint
class TmdbBulkItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final int? runtime;
  final String? overview;

  const TmdbBulkItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.releaseDate,
    this.runtime,
    this.overview,
  });

  factory TmdbBulkItem.fromJson(Map<String, dynamic> json) {
    return TmdbBulkItem(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String?,
      runtime: json['runtime'] as int?,
      overview: json['overview'] as String?,
    );
  }

  String? get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w342$posterPath'
      : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;

  int? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return int.tryParse(releaseDate!.split('-').first);
  }
}

/// Carga detalles de TMDB para una lista de MediaStates usando bulk endpoint
Future<List<LibraryItemWithDetails>> _loadItemsWithDetailsBulk(
  List<MediaState> states,
  SupabaseClient client, {
  String language = 'es-ES',
  String? region,
}) async {
  if (states.isEmpty) return [];

  // Separar por tipo de contenido
  final movieStates = states.where((s) => s.contentType == ContentType.movie).toList();
  final tvStates = states.where((s) => s.contentType == ContentType.tv).toList();

  // Fetch en paralelo movies y tv
  final results = await Future.wait([
    if (movieStates.isNotEmpty)
      client.callTmdbBulk(
        ids: movieStates.map((s) => s.tmdbId).toList(),
        contentType: 'movie',
        language: language,
        region: region,
      )
    else
      Future.value(<Map<String, dynamic>>[]),
    if (tvStates.isNotEmpty)
      client.callTmdbBulk(
        ids: tvStates.map((s) => s.tmdbId).toList(),
        contentType: 'tv',
        language: language,
        region: region,
      )
    else
      Future.value(<Map<String, dynamic>>[]),
  ]);

  final movieItems = results[0];
  final tvItems = results.length > 1 ? results[1] : <Map<String, dynamic>>[];

  // Crear mapa de id -> BulkItem
  final itemsMap = <int, TmdbBulkItem>{};
  for (final json in movieItems) {
    final item = TmdbBulkItem.fromJson(json);
    itemsMap[item.id] = item;
  }
  for (final json in tvItems) {
    final item = TmdbBulkItem.fromJson(json);
    itemsMap[item.id] = item;
  }

  // Combinar con states
  return states.map((state) {
    return LibraryItemWithDetails(
      state: state,
      bulkItem: itemsMap[state.tmdbId],
    );
  }).toList();
}

/// Provider para watchlist con detalles de TMDB (usa bulk endpoint)
final watchlistWithDetailsProvider =
    FutureProvider.autoDispose<List<LibraryItemWithDetails>>((ref) async {
  final states = await ref.watch(watchlistProvider.future);
  final client = ref.watch(supabaseClientProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return _loadItemsWithDetailsBulk(
    states,
    client,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});

/// Provider para favoritos con detalles de TMDB (usa bulk endpoint)
final favoritesWithDetailsProvider =
    FutureProvider.autoDispose<List<LibraryItemWithDetails>>((ref) async {
  final states = await ref.watch(favoritesProvider.future);
  final client = ref.watch(supabaseClientProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return _loadItemsWithDetailsBulk(
    states,
    client,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});

/// Provider para vistos con detalles de TMDB (usa bulk endpoint)
final watchedWithDetailsProvider =
    FutureProvider.autoDispose<List<LibraryItemWithDetails>>((ref) async {
  final states = await ref.watch(watchedProvider.future);
  final client = ref.watch(supabaseClientProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return _loadItemsWithDetailsBulk(
    states,
    client,
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});
