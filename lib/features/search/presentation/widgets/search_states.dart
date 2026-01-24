import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'filter_chips.dart';
import 'poster_grid_item.dart';
import 'search_bar_premium.dart';

/// Header de búsqueda "INTELLIGENT Discovery"
class SearchHeader extends StatelessWidget {
  final String? avatarUrl;
  final bool hasNotifications;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;

  const SearchHeader({
    super.key,
    this.avatarUrl,
    this.hasNotifications = false,
    this.onAvatarTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.strings.searchIntelligent.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: colors.accent,
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.strings.searchDiscovery,
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Notification button
          GestureDetector(
            onTap: onNotificationsTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    CupertinoIcons.bell,
                    color: colors.textPrimary,
                    size: 22,
                  ),
                  if (hasNotifications)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceElevated,
                border: Border.all(
                  color: colors.accent,
                  width: 2,
                ),
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? Icon(
                      CupertinoIcons.person_fill,
                      color: colors.textSecondary,
                      size: 22,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de resultados con título "AI Recommended"
class ResultsHeader extends StatelessWidget {
  final int? matchPercentage;

  const ResultsHeader({
    super.key,
    this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.strings.searchAiRecommended,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (matchPercentage != null)
            Text(
              '$matchPercentage% ${l10n.strings.searchMatch.toUpperCase()}',
              style: AppTypography.labelMedium.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}

/// Estado vacío premium
class SearchEmptyState extends StatelessWidget {
  final bool isInitial;

  const SearchEmptyState({
    super.key,
    this.isInitial = true,
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
            // Icon with gradient
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
                isInitial
                    ? CupertinoIcons.sparkles
                    : CupertinoIcons.search,
                size: 36,
                color: isInitial ? colors.accent : colors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isInitial
                  ? l10n.strings.searchEmptyTitle
                  : l10n.strings.searchNoResultsTitle,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              isInitial
                  ? l10n.strings.searchEmptySubtitle
                  : l10n.strings.searchNoResultsSubtitle,
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
}

/// Estado de carga completo con skeleton
class SearchLoadingState extends StatelessWidget {
  const SearchLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceElevated,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Column(
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
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar skeleton
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarSkeleton(),
            ),

            const SizedBox(height: 20),

            // Filter chips skeleton
            const FilterChipsSkeleton(),

            const SizedBox(height: 24),

            // Results header skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 140,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Grid skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return const PosterGridItemSkeleton();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid skeleton para resultados
class ResultsGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ResultsGridSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.surfaceElevated,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const PosterGridItemSkeleton();
        },
      ),
    );
  }
}
