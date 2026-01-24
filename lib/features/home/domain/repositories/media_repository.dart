import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/media_item.dart';
import '../entities/movie_details.dart';

/// Repositorio abstracto para media (películas y series)
abstract class MediaRepository {
  /// Obtiene películas en tendencia
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTrendingMovies({int page = 1});

  /// Obtiene series en tendencia
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTrendingTv({int page = 1});

  /// Obtiene películas populares
  Future<Either<Failure, PaginatedResult<MediaItem>>> getPopularMovies({int page = 1});

  /// Obtiene series populares
  Future<Either<Failure, PaginatedResult<MediaItem>>> getPopularTv({int page = 1});

  /// Obtiene películas mejor valoradas
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTopRatedMovies({int page = 1});

  /// Obtiene series mejor valoradas
  Future<Either<Failure, PaginatedResult<MediaItem>>> getTopRatedTv({int page = 1});

  /// Obtiene películas próximas a estrenar
  Future<Either<Failure, PaginatedResult<MediaItem>>> getUpcomingMovies({int page = 1});

  /// Obtiene películas en cartelera
  Future<Either<Failure, PaginatedResult<MediaItem>>> getNowPlayingMovies({int page = 1});

  /// Obtiene series que se están emitiendo
  Future<Either<Failure, PaginatedResult<MediaItem>>> getOnTheAirTv({int page = 1});

  /// Busca películas y series
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchMulti(String query, {int page = 1});

  /// Busca solo películas
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchMovies(String query, {int page = 1});

  /// Busca solo series
  Future<Either<Failure, PaginatedResult<MediaItem>>> searchTv(String query, {int page = 1});

  /// Obtiene detalles de una película
  Future<Either<Failure, MovieDetails>> getMovieDetails(int id);

  /// Obtiene detalles de una serie
  Future<Either<Failure, MovieDetails>> getTvDetails(int id);

  /// Descubre películas con filtros
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  });

  /// Descubre series con filtros
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverTv({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  });

  /// Descubre películas con parámetros extendidos (para AI search)
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverMoviesWithParams(
    Map<String, dynamic> params,
  );

  /// Descubre series con parámetros extendidos (para AI search)
  Future<Either<Failure, PaginatedResult<MediaItem>>> discoverTvWithParams(
    Map<String, dynamic> params,
  );

  /// Obtiene géneros de películas
  Future<Either<Failure, List<Genre>>> getMovieGenres();

  /// Obtiene géneros de series
  Future<Either<Failure, List<Genre>>> getTvGenres();
}

/// Resultado paginado genérico
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalResults;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  bool get hasMore => page < totalPages;
}
