/// Entidad de recomendación generada por AI
class AiRecommendationEntity {
  final int tmdbId;
  final String title;
  final String contentType;
  final String reason;
  final List<String> tags;
  final double confidence;

  // Campos opcionales para datos adicionales de TMDB
  final String? posterPath;
  final String? overview;
  final double? voteAverage;
  final String? releaseDate;

  const AiRecommendationEntity({
    required this.tmdbId,
    required this.title,
    required this.contentType,
    required this.reason,
    required this.tags,
    required this.confidence,
    this.posterPath,
    this.overview,
    this.voteAverage,
    this.releaseDate,
  });

  AiRecommendationEntity copyWith({
    int? tmdbId,
    String? title,
    String? contentType,
    String? reason,
    List<String>? tags,
    double? confidence,
    String? posterPath,
    String? overview,
    double? voteAverage,
    String? releaseDate,
  }) {
    return AiRecommendationEntity(
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      reason: reason ?? this.reason,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  /// Porcentaje de confianza formateado
  String get confidencePercent => '${(confidence * 100).round()}%';

  /// Si es película o serie
  bool get isMovie => contentType == 'movie';
  bool get isTvShow => contentType == 'tv';

  /// Color basado en confianza
  String get confidenceLevel {
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.6) return 'medium';
    return 'low';
  }
}

/// Resultado completo de la petición de recomendaciones
class AiRecommendResult {
  final bool success;
  final String prompt;
  final String contentType;
  final List<AiRecommendationEntity> recommendations;
  final UserHistoryStats userHistoryStats;

  const AiRecommendResult({
    required this.success,
    required this.prompt,
    required this.contentType,
    required this.recommendations,
    required this.userHistoryStats,
  });

  bool get hasRecommendations => recommendations.isNotEmpty;
}

/// Estadísticas del historial del usuario
class UserHistoryStats {
  final int watchlistCount;
  final int favoritesCount;
  final int watchedCount;
  final int ratingsCount;

  const UserHistoryStats({
    required this.watchlistCount,
    required this.favoritesCount,
    required this.watchedCount,
    required this.ratingsCount,
  });

  int get totalItems => watchlistCount + favoritesCount + watchedCount;
  
  bool get hasHistory => totalItems > 0 || ratingsCount > 0;
}
