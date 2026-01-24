import '../entities/ai_recommendation.dart';

/// Repositorio abstracto para operaciones de AI
abstract class AiRepository {
  /// Obtiene recomendaciones personalizadas basadas en el prompt y historial
  /// 
  /// [prompt] - Descripción de lo que busca el usuario
  /// [contentType] - Tipo de contenido: 'movie', 'tv', 'both'
  /// [limit] - Número máximo de recomendaciones (1-10)
  Future<AiRecommendResult> getRecommendations({
    required String prompt,
    String contentType = 'both',
    int limit = 5,
  });
}
