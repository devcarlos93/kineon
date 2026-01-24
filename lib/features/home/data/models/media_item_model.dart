import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/media_item.dart';

/// Modelo de datos para MediaItem que viene de la API
class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.title,
    super.originalTitle,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.voteAverage,
    super.voteCount,
    super.popularity,
    super.releaseDate,
    super.genreIds,
    required super.contentType,
    super.originalLanguage,
    super.adult,
  });

  /// Crear desde JSON de película
  factory MediaItemModel.fromMovieJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      contentType: ContentType.movie,
      originalLanguage: json['original_language'] as String?,
      adult: json['adult'] as bool? ?? false,
    );
  }

  /// Crear desde JSON de serie
  factory MediaItemModel.fromTvJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as int,
      title: json['name'] as String? ?? '',
      originalTitle: json['original_name'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      releaseDate: json['first_air_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      contentType: ContentType.tv,
      originalLanguage: json['original_language'] as String?,
      adult: json['adult'] as bool? ?? false,
    );
  }

  /// Crear desde JSON genérico (detecta si es película o serie)
  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    // Si tiene 'title' es película, si tiene 'name' es serie
    if (json.containsKey('title')) {
      return MediaItemModel.fromMovieJson(json);
    } else {
      return MediaItemModel.fromTvJson(json);
    }
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'media_type': contentType.value,
      'original_language': originalLanguage,
      'adult': adult,
    };
  }

  /// Convertir a entidad de dominio
  MediaItem toEntity() => this;
}

/// Respuesta paginada de la API
class PaginatedResponse<T> {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<T> results;

  const PaginatedResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  bool get hasMore => page < totalPages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convierte a JSON para caché (requiere que T tenga toJson)
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) {
    return {
      'page': page,
      'total_pages': totalPages,
      'total_results': totalResults,
      'results': results.map((e) => itemToJson(e)).toList(),
    };
  }
}
