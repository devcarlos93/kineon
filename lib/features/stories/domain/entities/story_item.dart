import '../../../home/domain/entities/media_item.dart';
import '../../../../core/constants/app_constants.dart';

/// Item de story: wraps MediaItem con hook corto para experiencia fullscreen
class StoryItem {
  final MediaItem item;
  final String hook;
  final int position;

  const StoryItem({
    required this.item,
    required this.hook,
    required this.position,
  });

  /// Crea desde JSON (compatible con respuesta de ai-home-picks en story_mode)
  factory StoryItem.fromJson(Map<String, dynamic> json, {int position = 0}) {
    return StoryItem(
      item: MediaItem(
        id: json['tmdb_id'] as int,
        title: json['title'] as String? ?? 'Sin titulo',
        overview: json['overview'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: 0,
        genreIds: (json['genre_ids'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        contentType: json['content_type'] == 'tv'
            ? ContentType.tv
            : ContentType.movie,
        releaseDate: json['release_date'] as String?,
      ),
      hook: json['reason'] as String? ?? '',
      position: position,
    );
  }

  /// Convierte a JSON para cache local
  Map<String, dynamic> toJson() {
    return {
      'tmdb_id': item.id,
      'title': item.title,
      'overview': item.overview,
      'poster_path': item.posterPath,
      'backdrop_path': item.backdropPath,
      'vote_average': item.voteAverage,
      'genre_ids': item.genreIds,
      'content_type': item.contentType == ContentType.tv ? 'tv' : 'movie',
      'release_date': item.releaseDate,
      'reason': hook,
    };
  }

  /// URL del backdrop en alta resolucion (w1280) para fullscreen
  String? get backdropUrlFullscreen => item.backdropPath != null
      ? '${AppConstants.tmdbBackdropLarge}${item.backdropPath}'
      : null;
}
