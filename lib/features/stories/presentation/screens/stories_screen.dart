import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../subscription/domain/entities/subscription_state.dart';
import '../../../subscription/presentation/helpers/gating_helper.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/stories_provider.dart';
import '../widgets/story_actions.dart';
import '../widgets/story_card.dart';
import '../widgets/story_progress_bar.dart';

/// Pantalla fullscreen de Stories tipo TikTok/Instagram
class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  Timer? _autoAdvanceTimer;
  Timer? _progressTimer;
  double _currentProgress = 0.0;
  bool _isPaused = false;
  bool _isGated = false;
  bool _showingProUpsell = false;

  static const _storyDuration = Duration(seconds: 8);
  static const _progressInterval = Duration(milliseconds: 50);
  static const _maxFreeStories = 3;

  bool get _isPro => ref.read(subscriptionProvider).isPro;

  @override
  void initState() {
    super.initState();
    // Immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Cargar stories y verificar gating
    Future.microtask(() => _initStories());
  }

  Future<void> _initStories() async {
    if (!mounted) return;

    // Pro users: verificar gating normal
    if (_isPro) {
      final canUse = await GatingHelper.checkAndGate(
        context,
        ref,
        AIEndpoints.stories,
      );

      if (!canUse) {
        _isGated = true;
        if (mounted) context.pop();
        return;
      }

      // Registrar uso
      await GatingHelper.recordUsage(ref, AIEndpoints.stories);
    }

    // Cargar stories
    await ref.read(storiesProvider.notifier).loadStories();

    if (mounted) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressTimer?.cancel();
    // Restaurar UI overlay
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  /// Obtiene las stories visibles (limitadas a 3 para free users)
  List<dynamic> _getVisibleStories(StoriesState state) {
    if (_isPro || state.stories.length <= _maxFreeStories) {
      return state.stories;
    }
    return state.stories.take(_maxFreeStories).toList();
  }

  void _startAutoAdvance() {
    _cancelTimers();
    setState(() => _currentProgress = 0.0);

    _progressTimer = Timer.periodic(_progressInterval, (timer) {
      if (_isPaused || _showingProUpsell) return;
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentProgress += _progressInterval.inMilliseconds /
            _storyDuration.inMilliseconds;
      });

      if (_currentProgress >= 1.0) {
        timer.cancel();
        _goToNextStory();
      }
    });
  }

  void _cancelTimers() {
    _autoAdvanceTimer?.cancel();
    _progressTimer?.cancel();
  }

  void _goToNextStory() {
    final state = ref.read(storiesProvider);
    final visibleStories = _getVisibleStories(state);
    final isLastVisible = state.currentIndex >= visibleStories.length - 1;

    if (isLastVisible) {
      // Free user con mas stories disponibles -> mostrar upsell de Kino
      if (!_isPro && state.stories.length > _maxFreeStories) {
        _cancelTimers();
        HapticFeedback.mediumImpact();
        setState(() => _showingProUpsell = true);
        return;
      }

      // Ultima story -> cerrar
      ref.read(storiesProvider.notifier).markCurrentAsViewed();
      if (mounted) context.pop();
    } else {
      ref.read(storiesProvider.notifier).nextStory();
      _startAutoAdvance();
    }
  }

  void _goToPreviousStory() {
    // Si estamos en el upsell, volver a la ultima story
    if (_showingProUpsell) {
      setState(() => _showingProUpsell = false);
      _startAutoAdvance();
      return;
    }

    final state = ref.read(storiesProvider);
    if (state.currentIndex > 0) {
      ref.read(storiesProvider.notifier).previousStory();
      _startAutoAdvance();
    } else {
      // Reiniciar story actual
      _startAutoAdvance();
    }
  }

  void _pause() {
    if (!_showingProUpsell) {
      setState(() => _isPaused = true);
    }
  }

  void _resume() {
    if (!_showingProUpsell) {
      setState(() => _isPaused = false);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_showingProUpsell) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth / 3) {
      _goToPreviousStory();
    } else if (tapX > screenWidth * 2 / 3) {
      _goToNextStory();
    }
  }

  void _onVerticalDrag(DragEndDetails details) {
    if (_showingProUpsell) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      // Swipe up -> next
      _goToNextStory();
    } else if (velocity > 300) {
      // Swipe down -> previous
      _goToPreviousStory();
    }
  }

  void _onDetailsTap() {
    final state = ref.read(storiesProvider);
    final story = state.currentStory;
    if (story != null) {
      final type = story.item.isMovie ? 'movie' : 'tv';
      context.push('/details/$type/${story.item.id}');
    }
  }

  Future<void> _onUpgradeTap() async {
    HapticFeedback.mediumImpact();
    await RevenueCatUI.presentPaywall();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storiesProvider);

    if (_isGated) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
      );
    }

    if (state.isLoading && state.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5EEAD4),
          ),
        ),
      );
    }

    if (state.error != null && state.stories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Volver',
                    style: TextStyle(color: Color(0xFF5EEAD4))),
              ),
            ],
          ),
        ),
      );
    }

    if (state.stories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No hay stories disponibles',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Volver',
                    style: TextStyle(color: Color(0xFF5EEAD4))),
              ),
            ],
          ),
        ),
      );
    }

    final visibleStories = _getVisibleStories(state);
    final currentStory = state.currentStory;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: GestureDetector(
        onTapUp: _onTapUp,
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: _onVerticalDrag,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story cards
            IndexedStack(
              index: state.currentIndex,
              children: visibleStories.map((story) {
                return StoryCard(
                  story: story,
                  isActive: story.position == state.currentIndex,
                );
              }).toList(),
            ),

            // Progress bar (top)
            if (!_showingProUpsell)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StoryProgressBar(
                  storyCount: visibleStories.length,
                  currentIndex: state.currentIndex,
                  currentProgress: _currentProgress,
                ),
              ),

            // Close button (top-right)
            if (!_showingProUpsell)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 12,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

            // Action buttons (right side)
            if (currentStory != null && !_showingProUpsell)
              Positioned(
                right: 0,
                bottom: 0,
                child: StoryActions(
                  item: currentStory.item,
                  onDetailsTap: _onDetailsTap,
                ),
              ),

            // Pro upsell overlay con Kino excited
            if (_showingProUpsell)
              _ProUpsellOverlay(
                remainingCount: state.stories.length - _maxFreeStories,
                onUpgrade: _onUpgradeTap,
                onClose: () {
                  if (mounted) context.pop();
                },
                onBack: _goToPreviousStory,
              ),
          ],
        ),
      ),
    );
  }
}

/// Overlay de upsell Pro con Kino excited
class _ProUpsellOverlay extends StatelessWidget {
  final int remainingCount;
  final VoidCallback onUpgrade;
  final VoidCallback onClose;
  final VoidCallback onBack;

  const _ProUpsellOverlay({
    required this.remainingCount,
    required this.onUpgrade,
    required this.onClose,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B0F14).withValues(alpha: 0.95),
            const Color(0xFF0B0F14),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar con botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido central
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kino excited grande
                    const KinoMascot(size: 120, mood: KinoMood.excited),

                    const SizedBox(height: 32),

                    // Titulo
                    Text(
                      l10n.storiesProTitle,
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Contador de stories restantes
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5EEAD4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF5EEAD4).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '+$remainingCount historias',
                        style: const TextStyle(
                          color: Color(0xFF5EEAD4),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitulo
                    Text(
                      l10n.storiesProSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // CTA Button con gradiente
                    GestureDetector(
                      onTap: onUpgrade,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5EEAD4)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.storiesProCta,
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip text
                    GestureDetector(
                      onTap: onClose,
                      child: Text(
                        l10n.storiesEndAction,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
