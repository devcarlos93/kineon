import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/ai_recommendation.dart';
import '../providers/ai_provider.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _promptController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPrompt() {
    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) {
      ref.read(aiRecommendationsProvider.notifier).getRecommendations(prompt);
      _focusNode.unfocus();
      
      // Agregar al historial
      final history = ref.read(promptHistoryProvider);
      if (!history.contains(prompt)) {
        ref.read(promptHistoryProvider.notifier).state = [prompt, ...history].take(10).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiRecommendationsProvider);
    final suggestedPrompts = ref.watch(suggestedPromptsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Filtro de contenido
            _buildFilterChips(context, state.filter),
            
            // Campo de búsqueda
            _buildSearchField(context, state.isLoading),
            
            // Contenido principal
            Expanded(
              child: state.isLoading
                  ? _buildLoadingState()
                  : state.error != null
                      ? _buildErrorState(state.error!)
                      : state.hasResults
                          ? _buildResultsList(context, state.result!)
                          : _buildEmptyState(context, suggestedPrompts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente IA',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Descubre contenido personalizado',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AiContentFilter current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: AiContentFilter.values.map((filter) {
          final isSelected = filter == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(aiRecommendationsProvider.notifier).setFilter(filter);
              },
              backgroundColor: Colors.grey[900],
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey[800]!,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promptController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '¿Qué te gustaría ver hoy?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.psychology_outlined,
                    color: Colors.grey[600],
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                minLines: 1,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submitPrompt(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: isLoading ? null : _submitPrompt,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 24),
          Text(
            'Analizando tu historial...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generando recomendaciones personalizadas',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(aiRecommendationsProvider.notifier).clearError();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, List<SuggestedPrompt> prompts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Describe lo que buscas en tus propias palabras. La IA analizará tu historial para darte recomendaciones personalizadas.',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Suggested prompts title
          Text(
            'Prueba con estos ejemplos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          
          // Suggested prompts grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts.map((prompt) {
              return InkWell(
                onTap: () {
                  _promptController.text = prompt.text;
                  _submitPrompt();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(prompt.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          prompt.text,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, AiRecommendResult result) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Header con estadísticas
        _buildResultsHeader(context, result),
        const SizedBox(height: 16),
        
        // Lista de recomendaciones
        ...result.recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final rec = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecommendationCard(
              recommendation: rec,
              index: index + 1,
              onTap: () => _navigateToDetails(rec),
            ),
          );
        }),
        
        const SizedBox(height: 24),
        
        // Botón para nueva búsqueda
        Center(
          child: TextButton.icon(
            onPressed: () {
              ref.read(aiRecommendationsProvider.notifier).clear();
              _promptController.clear();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Nueva búsqueda'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(BuildContext context, AiRecommendResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${result.recommendations.length} recomendaciones',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${result.prompt}"',
            style: TextStyle(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
          if (result.userHistoryStats.hasHistory) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _StatChip(
                  icon: Icons.visibility,
                  label: '${result.userHistoryStats.watchedCount} vistas',
                ),
                _StatChip(
                  icon: Icons.favorite,
                  label: '${result.userHistoryStats.favoritesCount} favoritas',
                ),
                _StatChip(
                  icon: Icons.star,
                  label: '${result.userHistoryStats.ratingsCount} ratings',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToDetails(AiRecommendationEntity rec) {
    context.push('/details/${rec.contentType}/${rec.tmdbId}');
  }
}

// =====================================================
// WIDGETS AUXILIARES
// =====================================================

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final AiRecommendationEntity recommendation;
  final int index;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[850]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con número y tipo
            Row(
              children: [
                // Número de ranking
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Título
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            recommendation.isMovie 
                                ? Icons.movie_outlined 
                                : Icons.tv_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.isMovie ? 'Película' : 'Serie',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Confidence badge
                _ConfidenceBadge(confidence: recommendation.confidence),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Razón
            Text(
              recommendation.reason,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recommendation.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Ver más
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Ver detalles',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (confidence >= 0.8) {
      color = Colors.green;
    } else if (confidence >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
