import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ai_recommendation.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource _remoteDatasource;

  AiRepositoryImpl(this._remoteDatasource);

  @override
  Future<AiRecommendResult> getRecommendations({
    required String prompt,
    String contentType = 'both',
    int limit = 5,
  }) async {
    try {
      final response = await _remoteDatasource.getRecommendations(
        prompt: prompt,
        contentType: contentType,
        limit: limit,
      );

      return AiRecommendResult(
        success: response.success,
        prompt: response.prompt,
        contentType: response.contentType,
        recommendations: response.recommendations
            .map((r) => AiRecommendationEntity(
                  tmdbId: r.tmdbId,
                  title: r.title,
                  contentType: r.contentType,
                  reason: r.reason,
                  tags: r.tags,
                  confidence: r.confidence,
                ))
            .toList(),
        userHistoryStats: UserHistoryStats(
          watchlistCount: response.meta.watchlistCount,
          favoritesCount: response.meta.favoritesCount,
          watchedCount: response.meta.watchedCount,
          ratingsCount: response.meta.ratingsCount,
        ),
      );
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }
}
