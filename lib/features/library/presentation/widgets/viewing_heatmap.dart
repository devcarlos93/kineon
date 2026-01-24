import 'package:flutter/cupertino.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/library_repository.dart';

/// Widget de heatmap de visualización
class ViewingHeatmap extends StatelessWidget {
  final ViewingActivity data;
  final VoidCallback? onTap;

  const ViewingHeatmap({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strings.libraryViewingHeatmap.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textTertiary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.strings.libraryActiveActivity,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Change percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        data.changePercentage >= 0
                            ? CupertinoIcons.arrow_up_right
                            : CupertinoIcons.arrow_down_right,
                        color: data.changePercentage >= 0
                            ? colors.accent
                            : colors.error,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.changePercentage >= 0 ? '+' : ''}${data.changePercentage}%',
                        style: AppTypography.labelMedium.copyWith(
                          color: data.changePercentage >= 0
                              ? colors.accent
                              : colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Heatmap grid
            _HeatmapGrid(activityLevels: data.activityLevels),

            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.strings.libraryLast6Months,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      l10n.strings.libraryLess,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(5, (index) {
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: _getActivityColor(colors, index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                    const SizedBox(width: 3),
                    Text(
                      l10n.strings.libraryMore,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _getActivityColor(KineonColors colors, int level) {
    switch (level) {
      case 0:
        return colors.surfaceElevated;
      case 1:
        return colors.accent.withValues(alpha: 0.2);
      case 2:
        return colors.accent.withValues(alpha: 0.4);
      case 3:
        return colors.accent.withValues(alpha: 0.7);
      case 4:
        return colors.accent;
      default:
        return colors.surfaceElevated;
    }
  }
}

/// Grid del heatmap
class _HeatmapGrid extends StatelessWidget {
  final List<int> activityLevels;

  const _HeatmapGrid({required this.activityLevels});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Organizar en 4 filas x 6 columnas
    const rows = 4;
    const cols = 6;

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(cols, (col) {
            final index = row * cols + col;
            final level = index < activityLevels.length
                ? activityLevels[index]
                : 0;
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: ViewingHeatmap._getActivityColor(colors, level),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

/// Skeleton del heatmap
class ViewingHeatmapSkeleton extends StatelessWidget {
  const ViewingHeatmapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid skeleton
          ...List.generate(4, (row) {
            return Row(
              children: List.generate(6, (col) {
                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}
