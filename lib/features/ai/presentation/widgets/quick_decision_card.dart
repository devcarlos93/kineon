import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_ai_data.dart';

/// Card de decisión rápida con swipe para entrenar preferencias
class QuickDecisionCard extends StatefulWidget {
  final QuickDecisionItem item;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onSkip;

  const QuickDecisionCard({
    super.key,
    required this.item,
    required this.onLike,
    required this.onDislike,
    required this.onSkip,
  });

  @override
  State<QuickDecisionCard> createState() => _QuickDecisionCardState();
}

class _QuickDecisionCardState extends State<QuickDecisionCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  double _dragAngle = 0;
  bool _isDragging = false;

  static const double _swipeThreshold = 100;
  static const double _maxRotation = 0.3;

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragAngle = (_dragOffset / 300) * _maxRotation;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _swipeThreshold) {
      HapticFeedback.mediumImpact();
      if (_dragOffset > 0) {
        widget.onLike();
      } else {
        widget.onDislike();
      }
    }
    setState(() {
      _dragOffset = 0;
      _dragAngle = 0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final likeOpacity = (_dragOffset / _swipeThreshold).clamp(0.0, 1.0);
    final dislikeOpacity = (-_dragOffset / _swipeThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setTranslationRaw(_dragOffset, 0, 0)
          ..rotateZ(_dragAngle),
        child: Stack(
          children: [
            // Main card
            Container(
              width: 280,
              height: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Poster image
                    CachedNetworkImage(
                      imageUrl: widget.item.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceElevated,
                        child: const Center(child: CupertinoActivityIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colors.surfaceElevated,
                        child: Icon(
                          CupertinoIcons.film,
                          color: colors.textTertiary,
                          size: 60,
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.accent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              widget.item.type,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Title
                          Text(
                            widget.item.title,
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Year
                          Text(
                            '${widget.item.year}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Like overlay
                    if (likeOpacity > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.success.withValues(alpha: likeOpacity * 0.3),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: likeOpacity,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success.withValues(alpha: 0.9),
                                ),
                                child: const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Dislike overlay
                    if (dislikeOpacity > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: colors.error.withValues(alpha: dislikeOpacity * 0.3),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: dislikeOpacity,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.error.withValues(alpha: 0.9),
                                ),
                                child: const Icon(
                                  CupertinoIcons.xmark,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
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

/// Botones de acción para decisión rápida
class QuickDecisionButtons extends StatelessWidget {
  final VoidCallback onDislike;
  final VoidCallback onSkip;
  final VoidCallback onLike;

  const QuickDecisionButtons({
    super.key,
    required this.onDislike,
    required this.onSkip,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dislike button
        _CircleButton(
          icon: CupertinoIcons.xmark,
          color: colors.error,
          size: 56,
          iconSize: 24,
          onTap: () {
            HapticFeedback.mediumImpact();
            onDislike();
          },
        ),

        const SizedBox(width: 24),

        // Skip button
        _CircleButton(
          icon: CupertinoIcons.forward_fill,
          color: colors.textTertiary,
          size: 44,
          iconSize: 18,
          onTap: () {
            HapticFeedback.lightImpact();
            onSkip();
          },
        ),

        const SizedBox(width: 24),

        // Like button
        _CircleButton(
          icon: CupertinoIcons.heart_fill,
          color: AppColors.success,
          size: 56,
          iconSize: 24,
          onTap: () {
            HapticFeedback.mediumImpact();
            onLike();
          },
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Stack de cards para Quick Decision mode
class QuickDecisionStack extends StatelessWidget {
  final List<QuickDecisionItem> items;
  final int currentIndex;
  final Function(QuickDecisionItem) onLike;
  final Function(QuickDecisionItem) onDislike;
  final Function(QuickDecisionItem) onSkip;

  const QuickDecisionStack({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onLike,
    required this.onDislike,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (currentIndex >= items.length) {
      return const _EmptyStack();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background cards (stack effect)
        for (int i = 2; i >= 0; i--)
          if (currentIndex + i < items.length && i > 0)
            Transform.translate(
              offset: Offset(0, -i * 8.0),
              child: Transform.scale(
                scale: 1 - (i * 0.05),
                child: Opacity(
                  opacity: 1 - (i * 0.2),
                  child: Container(
                    width: 280,
                    height: 420,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: colors.surface,
                    ),
                  ),
                ),
              ),
            ),

        // Current card
        QuickDecisionCard(
          item: items[currentIndex],
          onLike: () => onLike(items[currentIndex]),
          onDislike: () => onDislike(items[currentIndex]),
          onSkip: () => onSkip(items[currentIndex]),
        ),
      ],
    );
  }
}

class _EmptyStack extends StatelessWidget {
  const _EmptyStack();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 280,
      height: 420,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: colors.accent,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Listo!',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Has completado todas las decisiones rápidas',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
