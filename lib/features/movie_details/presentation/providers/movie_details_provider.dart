import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../home/data/repositories/media_repository_impl.dart';
import '../../../home/domain/entities/movie_details.dart';
import '../../../home/domain/repositories/media_repository.dart';

/// Modelo para AI Insight
class AiInsight {
  final List<String> bullets;
  final List<String> tags;
  final int? matchScore;

  const AiInsight({
    required this.bullets,
    required this.tags,
    this.matchScore,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      bullets: List<String>.from(json['bullets'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      matchScore: json['match_score'] as int?,
    );
  }

  bool get isEmpty => bullets.isEmpty && tags.isEmpty;
}

/// Estado de detalles de película/serie
class MovieDetailsState {
  final MovieDetails? details;
  final bool isLoading;
  final String? error;

  const MovieDetailsState({
    this.details,
    this.isLoading = false,
    this.error,
  });

  MovieDetailsState copyWith({
    MovieDetails? details,
    bool? isLoading,
    String? error,
  }) {
    return MovieDetailsState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier de detalles
class MovieDetailsNotifier extends StateNotifier<MovieDetailsState> {
  final MediaRepository _repository;

  MovieDetailsNotifier(this._repository) : super(const MovieDetailsState());

  /// Carga detalles de una película
  Future<void> loadMovieDetails(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getMovieDetails(id);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (details) {
        state = state.copyWith(isLoading: false, details: details);
      },
    );
  }

  /// Carga detalles de una serie
  Future<void> loadTvDetails(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getTvDetails(id);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (details) {
        state = state.copyWith(isLoading: false, details: details);
      },
    );
  }

  /// Limpia el estado
  void clear() {
    state = const MovieDetailsState();
  }
}

/// Provider de detalles de película
final movieDetailsProvider = StateNotifierProvider.autoDispose<MovieDetailsNotifier, MovieDetailsState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  return MovieDetailsNotifier(repository);
});

/// Provider para cargar detalles de película por ID
final movieDetailsByIdProvider = FutureProvider.family.autoDispose<MovieDetails?, int>((ref, id) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final result = await repository.getMovieDetails(id);
  return result.fold((l) => null, (r) => r);
});

/// Provider para cargar detalles de serie por ID
final tvDetailsByIdProvider = FutureProvider.family.autoDispose<MovieDetails?, int>((ref, id) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final result = await repository.getTvDetails(id);
  return result.fold((l) => null, (r) => r);
});

// =====================================================
// AI INSIGHT PROVIDERS
// =====================================================

/// Parámetros para obtener AI insight
class AiInsightParams {
  final int tmdbId;
  final String contentType;
  final String title;
  final String overview;
  final List<String> genres;
  final double voteAverage;
  final int? runtime;
  final int? releaseYear;
  final String? director;

  const AiInsightParams({
    required this.tmdbId,
    required this.contentType,
    required this.title,
    required this.overview,
    required this.genres,
    required this.voteAverage,
    this.runtime,
    this.releaseYear,
    this.director,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiInsightParams &&
          runtimeType == other.runtimeType &&
          tmdbId == other.tmdbId &&
          contentType == other.contentType;

  @override
  int get hashCode => tmdbId.hashCode ^ contentType.hashCode;
}

/// Provider para obtener AI insight de una película/serie
/// Se ejecuta automáticamente cuando se proporcionan los parámetros
final aiInsightProvider = FutureProvider.family.autoDispose<AiInsight, AiInsightParams>((ref, params) async {
  final client = ref.watch(supabaseClientProvider);
  final analytics = ref.read(analyticsServiceProvider);

  try {
    final response = await client.callAiMovieInsight(
      tmdbId: params.tmdbId,
      contentType: params.contentType,
      title: params.title,
      overview: params.overview,
      genres: params.genres,
      voteAverage: params.voteAverage,
      runtime: params.runtime,
      releaseYear: params.releaseYear,
      director: params.director,
    );

    final insight = AiInsight.fromJson(response);

    // Track analytics
    analytics.trackEvent(
      AnalyticsEvents.aiInsightViewed,
      properties: {
        'tmdb_id': params.tmdbId,
        'content_type': params.contentType,
        'bullets_count': insight.bullets.length,
      },
    );

    return insight;
  } catch (e) {
    // En caso de error, retornar un insight vacío en lugar de fallar
    // para que la UI no se rompa
    print('Error getting AI insight: $e');
    return AiInsight(
      bullets: [],
      tags: params.genres.take(3).map((g) => g.toUpperCase()).toList(),
    );
  }
});
