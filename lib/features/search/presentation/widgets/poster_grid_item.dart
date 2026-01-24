import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_search_data.dart';

/// Item de poster para grid con quick actions
class PosterGridItem extends StatelessWidget {
  final MockSearchResult result;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onWatchlistTap;
  final VoidCallback onSeenTap;

  const PosterGridItem({
    super.key,
    required this.result,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onWatchlistTap,
    required this.onSeenTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster con quick actions
          Expanded(
            child: Stack(
              children: [
                // Poster image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: result.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceElevated,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colors.surfaceElevated,
                        child: Icon(
                          CupertinoIcons.film,
                          color: colors.textTertiary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick action buttons (vertical)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _QuickActionButton(
                        icon: result.isFavorite
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        isActive: result.isFavorite,
                        activeColor: const Color(0xFFFF4D6D),
                        onTap: onFavoriteTap,
                      ),
                      const SizedBox(height: 6),
                      _QuickActionButton(
                        icon: result.inWatchlist
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        isActive: result.inWatchlist,
                        activeColor: AppColors.accentLime,
                        onTap: onWatchlistTap,
                      ),
                      const SizedBox(height: 6),
                      _QuickActionButton(
                        icon: result.isSeen
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye,
                        isActive: result.isSeen,
                        activeColor: colors.accent,
                        onTap: onSeenTap,
                      ),
                    ],
                  ),
                ),

                // Genre badge + Runtime at bottom
                Positioned(
                  left: 8,
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _GenreBadge(genre: result.genre),
                      const SizedBox(width: 6),
                      Text(
                        result.formattedRuntime,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textOnAccent,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF000000).withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
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
            result.title,
            style: AppTypography.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Director
          Text(
            result.director,
            style: AppTypography.labelSmall.copyWith(
              color: colors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.9)
              : const Color(0xFF000000).withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? activeColor
                : AppColors.textOnAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textOnAccent,
          size: 16,
        ),
      ),
    );
  }
}

/// Badge de género
class _GenreBadge extends StatelessWidget {
  final String genre;

  const _GenreBadge({required this.genre});

  Color get _badgeColor {
    switch (genre.toUpperCase()) {
      case 'SCI-FI':
        return AppColors.accent;
      case 'THRILLER':
        return AppColors.accentPurple;
      case 'DRAMA':
        return const Color(0xFFFF8C42);
      case 'ACTION':
        return const Color(0xFFFF4D6D);
      case 'COMEDY':
        return const Color(0xFFFFD93D);
      case 'HORROR':
        return const Color(0xFF6B2D5C);
      case 'MYSTERY':
        return const Color(0xFF4A90A4);
      case 'ROMANCE':
        return const Color(0xFFFF69B4);
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        genre,
        style: AppTypography.overline.copyWith(
          color: AppColors.textOnAccent,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Skeleton de poster grid item
class PosterGridItemSkeleton extends StatelessWidget {
  const PosterGridItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 14,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
