import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/media_item.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../subscription/subscription.dart';
import '../providers/intelligent_search_provider.dart';

/// Pantalla de Intelligent Discovery
class IntelligentDiscoveryScreen extends ConsumerStatefulWidget {
  const IntelligentDiscoveryScreen({super.key});

  @override
  ConsumerState<IntelligentDiscoveryScreen> createState() =>
      _IntelligentDiscoveryScreenState();
}

class _IntelligentDiscoveryScreenState
    extends ConsumerState<IntelligentDiscoveryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _currentSuggestion = '';

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _rotateSuggestion();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _rotateSuggestion() {
    final random = Random();
    _currentSuggestion =
        searchSuggestions[random.nextInt(searchSuggestions.length)];
  }

  /// Búsqueda automática mientras escribe
  void _onSearchChanged(String query) {
    ref.read(intelligentSearchProvider.notifier).search(query);
  }

  /// Búsqueda explícita (enter, voz) - igual que automática
  void _onSearchSubmit(String query) {
    _onSearchChanged(query);
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();

    if (!_speechAvailable) {
      _showSpeechNotAvailable();
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);

      // Usar idioma de preferencias regionales (ej: "es-ES" -> "es_ES")
      final regionalPrefs = ref.read(regionalPrefsProvider);
      final localeId = regionalPrefs.languageTag.replaceAll('-', '_');

      await _speech.listen(
        onResult: (result) {
          _searchController.text = result.recognizedWords;
          if (result.finalResult) {
            _onSearchSubmit(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.search,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
  }

  void _showSpeechNotAvailable() {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reconocimiento de voz no disponible'),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToDetail(MediaItem item) {
    final type = item.contentType == ContentType.tv ? 'tv' : 'movie';
    context.push('/details/$type/${item.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(intelligentSearchProvider);
    final mediaQuery = MediaQuery.of(context);

    // Escuchar cuando se alcanza el límite y mostrar paywall
    ref.listen<IntelligentSearchState>(intelligentSearchProvider, (prev, next) {
      if (next.limitReached && !(prev?.limitReached ?? false)) {
        PaywallModal.show(
          context,
          endpoint: AIEndpoints.search,
          onUpgrade: () => context.push('/profile/subscription'),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Search Input
            _buildSearchInput(state),

            // Hint text
            if (state.query.isEmpty) _buildHintText(),

            // Intent summary (cuando hay plan)
            if (state.plan != null && !state.isLoadingPlan)
              _buildIntentSummary(state.plan!),

            // Filter Chips
            _buildFilterChips(state),

            // Content
            Expanded(
              child: _buildContent(state, mediaQuery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = context.colors;
    final subscription = ref.watch(subscriptionProvider);
    final usage = subscription.getUsage(AIEndpoints.search);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'INTELLIGENT',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.accent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Usage counter badge
                  AIUsageCounter(
                    remaining: usage.remaining,
                    total: usage.dailyLimit,
                    isPro: subscription.isPro,
                    onUpgradeTap: () => context.push('/profile/subscription'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Discovery',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(IntelligentSearchState state) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Sparkles icon
            Icon(
              CupertinoIcons.sparkles,
              color: colors.accent,
              size: 20,
            ),
            const SizedBox(width: 12),
            // Text field
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmit,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontFamily: AppTypography.bodyMedium.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  hintText: _isListening ? 'Escuchando...' : 'Algo como Interstellar...',
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.bodyMedium.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _isListening ? colors.error : colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            // Loading indicator
            if (state.isLoadingPlan)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                ),
              )
            // Listening indicator
            else if (_isListening)
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.mic_fill,
                    color: colors.error,
                    size: 22,
                  ),
                ),
              )
            // Mic button (default)
            else
              IconButton(
                onPressed: _toggleListening,
                icon: Icon(
                  CupertinoIcons.mic,
                  color: _speechAvailable ? colors.accent : colors.textTertiary,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintText() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Text(
        'Try "$_currentSuggestion"',
        style: AppTypography.caption.copyWith(
          color: colors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildIntentSummary(SearchPlan plan) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            color: colors.accent,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              plan.intentSummary,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(IntelligentSearchState state) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Genre chip
          _FilterChip(
            label: state.plan?.ui.genreLabel ?? l10n.strings.searchFilterGenre,
            isActive: state.plan?.discover.withGenres.isNotEmpty ?? false,
            onTap: () {
              // TODO: Show genre picker
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 12),
          // Mood chip
          _FilterChip(
            label: state.plan?.ui.moodLabel ?? l10n.strings.searchFilterMood,
            isActive: state.plan?.ui.moodLabel != null,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 12),
          // Runtime chip
          _FilterChip(
            label: state.plan?.ui.runtimeLabel ?? l10n.strings.searchFilterRuntime,
            isActive: state.plan?.ui.runtimeLabel != null,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 12),
          // Year chip
          _FilterChip(
            label: state.plan?.ui.yearLabel ?? l10n.strings.searchFilterYear,
            isActive: state.plan?.ui.yearLabel != null,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(IntelligentSearchState state, MediaQueryData mediaQuery) {
    // Empty state
    if (state.query.isEmpty) {
      return _buildEmptyState();
    }

    // Loading
    if (state.isLoading && state.results.isEmpty) {
      return _buildLoadingState();
    }

    // Error
    if (state.error != null && state.results.isEmpty) {
      return _buildErrorState(state.error!);
    }

    // Results
    if (state.hasResults) {
      return _buildResults(state, mediaQuery);
    }

    // No results
    return _buildNoResultsState();
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.accent.withValues(alpha: 0.2),
                    colors.accentPurple.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: colors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Búsqueda Inteligente',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe lo que quieres ver y nuestra IA encontrará las mejores opciones para ti',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.accent),
          const SizedBox(height: 16),
          Text(
            'Buscando contenido perfecto...',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: colors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.film,
              color: colors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra descripción',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(IntelligentSearchState state, MediaQueryData mediaQuery) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: AI Recommended + Match %
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Recommended',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.plan != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.plan!.matchPercent}% MATCH',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Grid de resultados
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 100 + mediaQuery.padding.bottom,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final item = state.results[index];
              return _DiscoveryCard(
                item: item,
                onTap: () => _navigateToDetail(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Chip de filtro
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? colors.accent.withValues(alpha: 0.15) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.accent : colors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? colors.accent : colors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: isActive ? colors.accent : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de película/serie para Discovery
class _DiscoveryCard extends ConsumerWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _DiscoveryCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final posterUrl = item.posterPath != null
        ? '${AppConstants.tmdbPosterMedium}${item.posterPath}'
        : null;

    // Determinar género principal para el badge
    final genreName = _getGenreName(item.genreIds.isNotEmpty ? item.genreIds.first : 0);

    // Obtener estado de biblioteca para este item
    final mediaStateAsync = ref.watch(
      mediaStateProvider(MediaStateParams(
        tmdbId: item.id,
        contentType: item.contentType,
      )),
    );

    final isFavorite = mediaStateAsync.valueOrNull?.isFavorite ?? false;
    final isInWatchlist = mediaStateAsync.valueOrNull?.isInWatchlist ?? false;
    final isWatched = mediaStateAsync.valueOrNull?.isWatched ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster con acciones
          Expanded(
            child: Stack(
              children: [
                // Poster
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => Container(
                              color: colors.surfaceElevated,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.accent,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(colors),
                          )
                        : _buildPlaceholder(colors),
                  ),
                ),

                // Quick action buttons - solo mostrar si hay algún estado activo
                if (isFavorite || isInWatchlist || isWatched)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        if (isFavorite)
                          _QuickActionButton(
                            icon: CupertinoIcons.heart_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .toggleFavorite(item.id, item.contentType);
                            },
                          ),
                        if (isFavorite && (isInWatchlist || isWatched))
                          const SizedBox(height: 8),
                        if (isInWatchlist)
                          _QuickActionButton(
                            icon: CupertinoIcons.bookmark_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .removeFromWatchlist(item.id, item.contentType);
                            },
                          ),
                        if (isInWatchlist && isWatched) const SizedBox(height: 8),
                        if (isWatched)
                          _QuickActionButton(
                            icon: CupertinoIcons.eye_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .removeFromWatched(item.id, item.contentType);
                            },
                          ),
                      ],
                    ),
                  ),

                // Genre badge + runtime (abajo izquierda)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      // Genre badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          genreName.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textOnAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Runtime (placeholder - necesita datos de detail)
                      Text(
                        item.releaseDate != null
                            ? item.releaseDate!.split('-').first
                            : '',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle (director/year placeholder)
          Text(
            item.releaseDate?.split('-').first ?? '',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Container(
      color: colors.surfaceElevated,
      child: Center(
        child: Icon(
          CupertinoIcons.film,
          color: colors.textTertiary,
          size: 40,
        ),
      ),
    );
  }

  String _getGenreName(int genreId) {
    const genreMap = {
      28: 'ACTION',
      12: 'ADVENTURE',
      16: 'ANIMATION',
      35: 'COMEDY',
      80: 'CRIME',
      99: 'DOCUMENTARY',
      18: 'DRAMA',
      10751: 'FAMILY',
      14: 'FANTASY',
      36: 'HISTORY',
      27: 'HORROR',
      10402: 'MUSIC',
      9648: 'MYSTERY',
      10749: 'ROMANCE',
      878: 'SCI-FI',
      53: 'THRILLER',
      10752: 'WAR',
      37: 'WESTERN',
      10759: 'ACTION',
      10765: 'SCI-FI',
    };
    return genreMap[genreId] ?? 'MOVIE';
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent
              : Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? AppColors.textOnAccent : Colors.white,
        ),
      ),
    );
  }
}
