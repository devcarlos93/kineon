import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'action_buttons.dart';
import 'ai_recommendation.dart';
import 'cast_section.dart';
import 'synopsis_section.dart';
import 'trailers_section.dart';

/// Estado de carga completo de la pantalla de detalle
class DetailLoadingState extends StatelessWidget {
  const DetailLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.55;

    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceElevated,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero skeleton
            _HeroSkeleton(height: heroHeight),

            const SizedBox(height: 24),

            // Action buttons skeleton
            const ActionButtonsSkeleton(),

            const SizedBox(height: 32),

            // Synopsis skeleton
            const SynopsisSkeleton(),

            const SizedBox(height: 32),

            // AI module skeleton
            const AIRecommendationSkeleton(),

            const SizedBox(height: 32),

            // Trailers skeleton
            const TrailersSkeleton(),

            const SizedBox(height: 32),

            // Cast skeleton
            const CastSkeleton(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  final double height;

  const _HeroSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: Container(color: colors.surface),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Content at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Poster
                Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 160,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            width: 60,
                            height: 28,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de error con opción de reintentar
class DetailErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onBack;

  const DetailErrorState({
    super.key,
    this.message,
    required this.onRetry,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return SafeArea(
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.surfaceBorder),
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: colors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Error content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with gradient background
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
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 36,
                        color: colors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      l10n.detailErrorLoading,
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),

                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Retry button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onRetry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.refresh,
                              color: colors.textOnAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.detailRetry,
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.textOnAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
