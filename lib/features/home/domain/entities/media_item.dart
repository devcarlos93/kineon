import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Entidad base para películas y series
class MediaItem extends Equatable {
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final String? releaseDate;
  final List<int> genreIds;
  final ContentType contentType;
  final String? originalLanguage;
  final bool adult;

  const MediaItem({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.popularity = 0,
    this.releaseDate,
    this.genreIds = const [],
    required this.contentType,
    this.originalLanguage,
    this.adult = false,
  });

  /// URL completa del poster
  String? get posterUrl => posterPath != null 
      ? '${AppConstants.tmdbPosterMedium}$posterPath'
      : null;

  /// URL completa del poster en alta resolución
  String? get posterUrlLarge => posterPath != null 
      ? '${AppConstants.tmdbPosterLarge}$posterPath'
      : null;

  /// URL completa del backdrop
  String? get backdropUrl => backdropPath != null 
      ? '${AppConstants.tmdbBackdropMedium}$backdropPath'
      : null;

  /// URL completa del backdrop en alta resolución
  String? get backdropUrlLarge => backdropPath != null 
      ? '${AppConstants.tmdbBackdropLarge}$backdropPath'
      : null;

  /// Año de lanzamiento
  int? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return int.tryParse(releaseDate!.split('-').first);
  }

  /// Rating formateado (ej: 7.5)
  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  /// Porcentaje de rating para UI (0-100)
  int get ratingPercent => (voteAverage * 10).round();

  /// Color basado en el rating
  RatingLevel get ratingLevel {
    if (voteAverage >= 7) return RatingLevel.high;
    if (voteAverage >= 5) return RatingLevel.medium;
    return RatingLevel.low;
  }

  /// Si es película o serie
  bool get isMovie => contentType == ContentType.movie;
  bool get isTv => contentType == ContentType.tv;

  @override
  List<Object?> get props => [
        id,
        title,
        originalTitle,
        overview,
        posterPath,
        backdropPath,
        voteAverage,
        voteCount,
        popularity,
        releaseDate,
        genreIds,
        contentType,
        originalLanguage,
        adult,
      ];

  MediaItem copyWith({
    int? id,
    String? title,
    String? originalTitle,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    double? popularity,
    String? releaseDate,
    List<int>? genreIds,
    ContentType? contentType,
    String? originalLanguage,
    bool? adult,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
      releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds,
      contentType: contentType ?? this.contentType,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      adult: adult ?? this.adult,
    );
  }

  /// Convierte a JSON para cache local
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
      'content_type': contentType == ContentType.tv ? 'tv' : 'movie',
      'original_language': originalLanguage,
      'adult': adult,
    };
  }

  /// Crea desde JSON del cache local
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
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
      contentType:
          json['content_type'] == 'tv' ? ContentType.tv : ContentType.movie,
      originalLanguage: json['original_language'] as String?,
      adult: json['adult'] as bool? ?? false,
    );
  }
}

enum RatingLevel { high, medium, low }
