import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../movie_details/presentation/providers/watch_providers_provider.dart';
import '../models/media_item_model.dart';
import '../models/movie_details_model.dart';

/// Provider para el datasource de TMDB
final tmdbRemoteDataSourceProvider = Provider<TmdbRemoteDataSource>((ref) {
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  return TmdbRemoteDataSourceImpl(
    ref.watch(supabaseClientProvider),
    language: regionalPrefs.tmdbLanguage,
    region: regionalPrefs.tmdbRegion,
  );
});

/// Interface del datasource remoto de TMDB
abstract class TmdbRemoteDataSource {
  /// Obtiene películas en tendencia
  Future<PaginatedResponse<MediaItemModel>> getTrendingMovies({int page = 1});

  /// Obtiene series en tendencia
  Future<PaginatedResponse<MediaItemModel>> getTrendingTv({int page = 1});

  /// Obtiene películas populares
  Future<PaginatedResponse<MediaItemModel>> getPopularMovies({int page = 1});

  /// Obtiene series populares
  Future<PaginatedResponse<MediaItemModel>> getPopularTv({int page = 1});

  /// Obtiene películas mejor valoradas
  Future<PaginatedResponse<MediaItemModel>> getTopRatedMovies({int page = 1});

  /// Obtiene series mejor valoradas
  Future<PaginatedResponse<MediaItemModel>> getTopRatedTv({int page = 1});

  /// Obtiene películas próximas a estrenar
  Future<PaginatedResponse<MediaItemModel>> getUpcomingMovies({int page = 1});

  /// Obtiene películas en cartelera
  Future<PaginatedResponse<MediaItemModel>> getNowPlayingMovies({int page = 1});

  /// Obtiene series que se están emitiendo
  Future<PaginatedResponse<MediaItemModel>> getOnTheAirTv({int page = 1});

  /// Busca películas y series
  Future<PaginatedResponse<MediaItemModel>> searchMulti(String query, {int page = 1});

  /// Busca solo películas
  Future<PaginatedResponse<MediaItemModel>> searchMovies(String query, {int page = 1});

  /// Busca solo series
  Future<PaginatedResponse<MediaItemModel>> searchTv(String query, {int page = 1});

  /// Obtiene detalles de una película
  Future<MovieDetailsModel> getMovieDetails(int id);

  /// Obtiene detalles de una serie
  Future<MovieDetailsModel> getTvDetails(int id);

  /// Obtiene películas similares
  Future<PaginatedResponse<MediaItemModel>> getSimilarMovies(int id, {int page = 1});

  /// Obtiene series similares
  Future<PaginatedResponse<MediaItemModel>> getSimilarTv(int id, {int page = 1});

  /// Obtiene recomendaciones de películas
  Future<PaginatedResponse<MediaItemModel>> getMovieRecommendations(int id, {int page = 1});

  /// Obtiene recomendaciones de series
  Future<PaginatedResponse<MediaItemModel>> getTvRecommendations(int id, {int page = 1});

  /// Descubre películas con filtros
  Future<PaginatedResponse<MediaItemModel>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  });

  /// Descubre series con filtros
  Future<PaginatedResponse<MediaItemModel>> discoverTv({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  });

  /// Descubre películas con parámetros extendidos (para AI search)
  Future<PaginatedResponse<MediaItemModel>> discoverMoviesWithParams(
    Map<String, dynamic> params,
  );

  /// Descubre series con parámetros extendidos (para AI search)
  Future<PaginatedResponse<MediaItemModel>> discoverTvWithParams(
    Map<String, dynamic> params,
  );

  /// Obtiene géneros de películas
  Future<List<GenreModel>> getMovieGenres();

  /// Obtiene géneros de series
  Future<List<GenreModel>> getTvGenres();

  /// Obtiene proveedores de streaming disponibles por región
  Future<List<WatchProvider>> getAvailableWatchProviders({String mediaType = 'movie'});
}

/// Implementación del datasource remoto de TMDB usando Edge Functions
class TmdbRemoteDataSourceImpl implements TmdbRemoteDataSource {
  final SupabaseClient _client;
  final String language;
  final String region;

  TmdbRemoteDataSourceImpl(
    this._client, {
    this.language = 'es-ES',
    this.region = 'ES',
  });

  /// Llama a la Edge Function de TMDB proxy
  Future<Map<String, dynamic>> _callTmdbProxy(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _client.functions.invoke(
        EdgeFunctions.tmdbProxy,
        body: {
          'path': path,
          'query': query ?? {},
          'language': language,
          'region': region,
        },
      );

      if (response.status != 200) {
        throw ServerException(
          message: 'Error del servidor TMDB: ${response.status}',
          code: response.status.toString(),
        );
      }

      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw ServerException(message: e.reasonPhrase ?? 'Error en Edge Function');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getTrendingMovies({int page = 1}) async {
    final data = await _callTmdbProxy('trending/movie/week', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getTrendingTv({int page = 1}) async {
    final data = await _callTmdbProxy('trending/tv/week', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getPopularMovies({int page = 1}) async {
    final data = await _callTmdbProxy('movie/popular', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getPopularTv({int page = 1}) async {
    final data = await _callTmdbProxy('tv/popular', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getTopRatedMovies({int page = 1}) async {
    final data = await _callTmdbProxy('movie/top_rated', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getTopRatedTv({int page = 1}) async {
    final data = await _callTmdbProxy('tv/top_rated', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getUpcomingMovies({int page = 1}) async {
    // Usar discover con filtro de fecha para obtener solo estrenos futuros
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    // Próximos 6 meses
    final sixMonthsLater = DateTime(now.year, now.month + 6, now.day);
    final endDate = '${sixMonthsLater.year}-${sixMonthsLater.month.toString().padLeft(2, '0')}-${sixMonthsLater.day.toString().padLeft(2, '0')}';

    final data = await _callTmdbProxy('discover/movie', query: {
      'page': page,
      'primary_release_date.gte': today,
      'primary_release_date.lte': endDate,
      'sort_by': 'primary_release_date.asc',
      'with_release_type': '2|3', // Theatrical releases
    });
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getNowPlayingMovies({int page = 1}) async {
    final data = await _callTmdbProxy('movie/now_playing', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getOnTheAirTv({int page = 1}) async {
    final data = await _callTmdbProxy('tv/on_the_air', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> searchMulti(String query, {int page = 1}) async {
    final data = await _callTmdbProxy('search/multi', query: {
      'query': query,
      'page': page,
      'include_adult': false,
    });
    return PaginatedResponse.fromJson(data, (json) {
      final mediaType = json['media_type'] as String?;
      if (mediaType == 'movie') {
        return MediaItemModel.fromMovieJson(json);
      } else if (mediaType == 'tv') {
        return MediaItemModel.fromTvJson(json);
      }
      // Por defecto tratamos como película
      return MediaItemModel.fromJson(json);
    });
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> searchMovies(String query, {int page = 1}) async {
    final data = await _callTmdbProxy('search/movie', query: {
      'query': query,
      'page': page,
      'include_adult': false,
    });
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> searchTv(String query, {int page = 1}) async {
    final data = await _callTmdbProxy('search/tv', query: {
      'query': query,
      'page': page,
      'include_adult': false,
    });
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<MovieDetailsModel> getMovieDetails(int id) async {
    final data = await _callTmdbProxy('movie/$id', query: {
      'append_to_response': 'credits,videos,similar,recommendations,watch/providers',
    });
    return MovieDetailsModel.fromJson(data);
  }

  @override
  Future<MovieDetailsModel> getTvDetails(int id) async {
    final data = await _callTmdbProxy('tv/$id', query: {
      'append_to_response': 'credits,videos,similar,recommendations,watch/providers',
    });
    return MovieDetailsModel.fromJson(data);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getSimilarMovies(int id, {int page = 1}) async {
    final data = await _callTmdbProxy('movie/$id/similar', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getSimilarTv(int id, {int page = 1}) async {
    final data = await _callTmdbProxy('tv/$id/similar', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getMovieRecommendations(int id, {int page = 1}) async {
    final data = await _callTmdbProxy('movie/$id/recommendations', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> getTvRecommendations(int id, {int page = 1}) async {
    final data = await _callTmdbProxy('tv/$id/recommendations', query: {'page': page});
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (genreIds != null && genreIds.isNotEmpty) {
      params['with_genres'] = genreIds.join(',');
    }
    if (year != null) {
      params['primary_release_year'] = year;
    }
    if (sortBy != null) {
      params['sort_by'] = sortBy;
    }
    final data = await _callTmdbProxy('discover/movie', query: params);
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> discoverTv({
    int page = 1,
    List<int>? genreIds,
    int? year,
    String? sortBy,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (genreIds != null && genreIds.isNotEmpty) {
      params['with_genres'] = genreIds.join(',');
    }
    if (year != null) {
      params['first_air_date_year'] = year;
    }
    if (sortBy != null) {
      params['sort_by'] = sortBy;
    }
    final data = await _callTmdbProxy('discover/tv', query: params);
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<List<GenreModel>> getMovieGenres() async {
    final data = await _callTmdbProxy('genre/movie/list');
    final genres = data['genres'] as List<dynamic>;
    return genres.map((g) => GenreModel.fromJson(g as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<GenreModel>> getTvGenres() async {
    final data = await _callTmdbProxy('genre/tv/list');
    final genres = data['genres'] as List<dynamic>;
    return genres.map((g) => GenreModel.fromJson(g as Map<String, dynamic>)).toList();
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> discoverMoviesWithParams(
    Map<String, dynamic> params,
  ) async {
    final data = await _callTmdbProxy('discover/movie', query: params);
    return PaginatedResponse.fromJson(data, MediaItemModel.fromMovieJson);
  }

  @override
  Future<PaginatedResponse<MediaItemModel>> discoverTvWithParams(
    Map<String, dynamic> params,
  ) async {
    final data = await _callTmdbProxy('discover/tv', query: params);
    return PaginatedResponse.fromJson(data, MediaItemModel.fromTvJson);
  }

  @override
  Future<List<WatchProvider>> getAvailableWatchProviders({String mediaType = 'movie'}) async {
    final data = await _callTmdbProxy('watch/providers/$mediaType', query: {
      'watch_region': region,
    });
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
