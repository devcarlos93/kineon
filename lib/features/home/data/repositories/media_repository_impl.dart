import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/tmdb_remote_datasource.dart';
import '../models/media_item_model.dart';

/// Provider para el repositorio de media
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final lang = ref.watch(regionalPrefsProvider).languageCode;
  return MediaRepositoryImpl(
    ref.watch(tmdbRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
    ref.watch(connectivityProvider),
    languageCode: lang,
  );
});

/// Implementación del repositorio de media con soporte offline
class MediaRepositoryImpl implements MediaRepository {
  final TmdbRemoteDataSource _remoteDataSource;
  final CacheService _cache;
  final ConnectivityStatus _connectivity;
  final String _lang;

  MediaRepositoryImpl(this._remoteDataSource, this._cache, this._connectivity, {String languageCode = 'es'}) : _lang = languageCode;

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTrendingMovies({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.trending('movie', 'week')}_$page',
      ttlMinutes: CacheService.ttlTrending,
      fetch: () => _remoteDataSource.getTrendingMovies(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTrendingTv({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.trending('tv', 'week')}_$page',
      ttlMinutes: CacheService.ttlTrending,
      fetch: () => _remoteDataSource.getTrendingTv(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getPopularMovies({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.popular('movie')}_$page',
      ttlMinutes: CacheService.ttlPopular,
      fetch: () => _remoteDataSource.getPopularMovies(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getPopularTv({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.popular('tv')}_$page',
      ttlMinutes: CacheService.ttlPopular,
      fetch: () => _remoteDataSource.getPopularTv(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTopRatedMovies({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.topRated('movie')}_$page',
      ttlMinutes: CacheService.ttlDetails,
      fetch: () => _remoteDataSource.getTopRatedMovies(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTopRatedTv({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.topRated('tv')}_$page',
      ttlMinutes: CacheService.ttlDetails,
      fetch: () => _remoteDataSource.getTopRatedTv(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getUpcomingMovies({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.upcoming()}_$page',
      ttlMinutes: CacheService.ttlTrending,
      fetch: () => _remoteDataSource.getUpcomingMovies(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getNowPlayingMovies({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_${CacheKeys.nowPlaying()}_$page',
      ttlMinutes: CacheService.ttlTrending,
      fetch: () => _remoteDataSource.getNowPlayingMovies(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> getOnTheAirTv({int page = 1}) async {
    return _executeWithCacheFallback(
      cacheKey: '${_lang}_on_the_air_tv_$page',
      ttlMinutes: CacheService.ttlTrending,
      fetch: () => _remoteDataSource.getOnTheAirTv(page: page),
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchMulti(String query, {int page = 1}) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.searchMulti(query, page: page);
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchMovies(String query, {int page = 1}) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.searchMovies(query, page: page);
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchTv(String query, {int page = 1}) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.searchTv(query, page: page);
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, MovieDetails>> getMovieDetails(int id) async {
    return _executeWithErrorHandling(() async {
      return await _remoteDataSource.getMovieDetails(id);
    });
  }

  @override
  Future<Either<Failure, MovieDetails>> getTvDetails(int id) async {
    return _executeWithErrorHandling(() async {
      return await _remoteDataSource.getTvDetails(id);
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  }) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.discoverMovies(
        page: page,
        genreIds: genreIds,
        year: year,
        sortBy: sortBy,
      );
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverTv({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  }) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.discoverTv(
        page: page,
        genreIds: genreIds,
        year: year,
        sortBy: sortBy,
      );
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, List<Genre>>> getMovieGenres() async {
    return _executeWithErrorHandling(() async {
      return await _remoteDataSource.getMovieGenres();
    });
  }

  @override
  Future<Either<Failure, List<Genre>>> getTvGenres() async {
    return _executeWithErrorHandling(() async {
      return await _remoteDataSource.getTvGenres();
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverMoviesWithParams(
    Map<String, dynamic> params,
  ) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.discoverMoviesWithParams(params);
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  @override
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverTvWithParams(
    Map<String, dynamic> params,
  ) async {
    return _executeWithErrorHandling(() async {
      final response = await _remoteDataSource.discoverTvWithParams(params);
      return PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
    });
  }

  /// Ejecuta una función con manejo de errores estándar
  Future<Either<Failure, T>> _executeWithErrorHandling<T>(
    Future<T> Function() function,
  ) async {
    try {
      final result = await function();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Ejecuta con cache fallback para listas paginadas de MediaItem
  Future<Either<Failure, PaginatedResult<MediaItem>>> _executeWithCacheFallback({
    required String cacheKey,
    required Future<PaginatedResponse<MediaItemModel>> Function() fetch,
    int ttlMinutes = CacheService.ttlPopular,
  }) async {
    // Si está offline, ir directo al caché
    if (_connectivity.isOffline) {
      final cached = _cache.getStale<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        final response = PaginatedResponse.fromJson(cached, MediaItemModel.fromJson);
        return Right(PaginatedResult(
          items: response.results,
          page: response.page,
          totalPages: response.totalPages,
          totalResults: response.totalResults,
        ));
      }
      return const Left(NetworkFailure(message: 'Sin conexión y sin datos guardados'));
    }

    // Si hay caché válido (no expirado), usarlo inmediatamente
    final validCache = _cache.get<Map<String, dynamic>>(cacheKey);
    if (validCache != null) {
      final response = PaginatedResponse.fromJson(validCache, MediaItemModel.fromJson);
      return Right(PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      ));
    }

    // Sin caché válido, intentar fetch remoto
    try {
      final response = await fetch();
      // Guardar en caché
      _cache.put(
        cacheKey,
        response.toJson((item) => item.toJson()),
        ttlMinutes: ttlMinutes,
      );
      return Right(PaginatedResult(
        items: response.results,
        page: response.page,
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      ));
    } catch (e) {
      // En cualquier error, intentar caché stale
      final cached = _cache.getStale<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        final response = PaginatedResponse.fromJson(cached, MediaItemModel.fromJson);
        return Right(PaginatedResult(
          items: response.results,
          page: response.page,
          totalPages: response.totalPages,
          totalResults: response.totalResults,
        ));
      }
      // Si no hay caché, propagar el error
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, code: e.code));
      }
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
