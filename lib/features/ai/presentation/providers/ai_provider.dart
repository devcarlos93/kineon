import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_recommendation.dart';
import '../../domain/repositories/ai_repository.dart';

// =====================================================
// PROVIDERS
// =====================================================

/// Datasource de AI
final aiRemoteDatasourceProvider = Provider<AiRemoteDatasource>((ref) {
  return AiRemoteDatasource(Supabase.instance.client);
});

/// Repositorio de AI
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(ref.read(aiRemoteDatasourceProvider));
});

/// Estado de las recomendaciones
final aiRecommendationsProvider = StateNotifierProvider<
    AiRecommendationsNotifier, AiRecommendationsState>((ref) {
  return AiRecommendationsNotifier(
    ref.read(aiRepositoryProvider),
    ref.read(analyticsServiceProvider),
  );
});

/// Provider para historial de prompts
final promptHistoryProvider = StateProvider<List<String>>((ref) => []);

// =====================================================
// STATE
// =====================================================

enum AiContentFilter {
  all('both', 'Todo'),
  movies('movie', 'Películas'),
  tvShows('tv', 'Series');

  final String value;
  final String label;
  const AiContentFilter(this.value, this.label);
}

class AiRecommendationsState {
  final bool isLoading;
  final String? error;
  final AiRecommendResult? result;
  final String lastPrompt;
  final AiContentFilter filter;

  const AiRecommendationsState({
    this.isLoading = false,
    this.error,
    this.result,
    this.lastPrompt = '',
    this.filter = AiContentFilter.all,
  });

  AiRecommendationsState copyWith({
    bool? isLoading,
    String? error,
    AiRecommendResult? result,
    String? lastPrompt,
    AiContentFilter? filter,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AiRecommendationsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
      lastPrompt: lastPrompt ?? this.lastPrompt,
      filter: filter ?? this.filter,
    );
  }

  bool get hasResults => result != null && result!.hasRecommendations;
  bool get isEmpty => !isLoading && result == null && error == null;
}

// =====================================================
// NOTIFIER
// =====================================================

class AiRecommendationsNotifier extends StateNotifier<AiRecommendationsState> {
  final AiRepository _repository;
  final AnalyticsService _analytics;

  AiRecommendationsNotifier(this._repository, this._analytics)
      : super(const AiRecommendationsState());

  /// Obtiene recomendaciones basadas en el prompt
  Future<void> getRecommendations(String prompt, {int limit = 5}) async {
    if (prompt.trim().length < 3) {
      state = state.copyWith(
        error: 'El prompt debe tener al menos 3 caracteres',
        clearResult: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      lastPrompt: prompt.trim(),
    );

    try {
      final result = await _repository.getRecommendations(
        prompt: prompt.trim(),
        contentType: state.filter.value,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
      );

      // Track analytics
      _analytics.trackEvent(
        AnalyticsEvents.aiSearchUsed,
        properties: {
          'filter': state.filter.value,
          'results_count': result.recommendations.length,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cambia el filtro de tipo de contenido
  void setFilter(AiContentFilter filter) {
    state = state.copyWith(filter: filter);
    
    // Si hay un prompt previo, re-ejecutar búsqueda
    if (state.lastPrompt.isNotEmpty) {
      getRecommendations(state.lastPrompt);
    }
  }

  /// Limpia los resultados
  void clear() {
    state = const AiRecommendationsState();
  }

  /// Limpia solo el error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// =====================================================
// PROMPTS SUGERIDOS
// =====================================================

final suggestedPromptsProvider = Provider<List<SuggestedPrompt>>((ref) {
  return const [
    SuggestedPrompt(
      text: 'Algo como Interstellar pero más corto',
      icon: '🚀',
    ),
    SuggestedPrompt(
      text: 'Thrillers psicológicos que no sean violentos',
      icon: '🧠',
    ),
    SuggestedPrompt(
      text: 'Comedias románticas de los 90s',
      icon: '💕',
    ),
    SuggestedPrompt(
      text: 'Documentales sobre naturaleza',
      icon: '🌍',
    ),
    SuggestedPrompt(
      text: 'Series de misterio con pocos capítulos',
      icon: '🔍',
    ),
    SuggestedPrompt(
      text: 'Películas animadas para adultos',
      icon: '🎬',
    ),
    SuggestedPrompt(
      text: 'Algo para ver con mi familia un domingo',
      icon: '👨‍👩‍👧‍👦',
    ),
    SuggestedPrompt(
      text: 'Ciencia ficción con buenas ideas pero bajo presupuesto',
      icon: '🛸',
    ),
  ];
});

class SuggestedPrompt {
  final String text;
  final String icon;

  const SuggestedPrompt({required this.text, required this.icon});
}
