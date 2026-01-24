import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:shimmer/shimmer.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Header de la pantalla de IA
class AiHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHistoryTap;

  const AiHeader({
    super.key,
    this.onSettingsTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        12,
      ),
      child: Row(
        children: [
          // AI Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.accent,
                  colors.accentPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.strings.aiTitle,
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.strings.aiSubtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // History button
          if (onHistoryTap != null)
            GestureDetector(
              onTap: onHistoryTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.surfaceBorder),
                ),
                child: Icon(
                  CupertinoIcons.time,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
            ),

          if (onSettingsTap != null) ...[
            const SizedBox(width: 8),

            // Settings button
            GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.surfaceBorder),
                ),
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton de carga para la pantalla de IA
class AiLoadingSkeleton extends StatelessWidget {
  const AiLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI message skeleton
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recommendation cards skeleton
            ...List.generate(2, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Estado de error para la pantalla de IA
class AiErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const AiErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: colors.error,
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.strings.aiErrorTitle,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message ?? l10n.strings.aiErrorMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Retry button
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.strings.aiRetry,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textOnAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header para Quick Decision mode
class QuickDecisionHeader extends StatelessWidget {
  final VoidCallback onClose;
  final int current;
  final int total;

  const QuickDecisionHeader({
    super.key,
    required this.onClose,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final progress = total > 0 ? current / total : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 8,
        20,
        16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Close button
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.surfaceBorder),
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strings.aiQuickDecision,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.strings.aiQuickDecisionSubtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$current / $total',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
