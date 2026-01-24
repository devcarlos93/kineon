import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Sección de sinopsis con texto expandible y opción de ocultar spoilers
class SynopsisSection extends StatefulWidget {
  final String synopsis;
  final bool hideSpoilers;

  const SynopsisSection({
    super.key,
    required this.synopsis,
    this.hideSpoilers = false,
  });

  @override
  State<SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<SynopsisSection> {
  bool _isExpanded = false;
  bool _spoilersRevealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final shouldHide = widget.hideSpoilers && !_spoilersRevealed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.detailSynopsis,
            style: AppTypography.overline.copyWith(
              color: colors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Synopsis content con posible blur
          Stack(
            children: [
              // Texto de la sinopsis
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  widget.synopsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.synopsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),

              // Overlay de blur cuando hideSpoilers está activo
              if (shouldHide)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _revealSpoilers,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.surfaceBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.eye_slash,
                                        color: colors.textSecondary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.strings.detailTapToReveal,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (widget.synopsis.length > 200 && !shouldHide)
            CupertinoButton(
              padding: const EdgeInsets.only(top: 8),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded
                        ? l10n.strings.detailShowLess
                        : l10n.strings.detailShowMore,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: colors.accent,
                    size: 14,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _revealSpoilers() {
    HapticFeedback.mediumImpact();
    setState(() {
      _spoilersRevealed = true;
    });
  }
}

/// Skeleton para la sinopsis
class SynopsisSkeleton extends StatelessWidget {
  const SynopsisSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
