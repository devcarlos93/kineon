import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Botones de acción: Watchlist, Favorito, Visto, Añadir a Lista
class ActionButtonsRow extends StatelessWidget {
  final bool inWatchlist;
  final bool isFavorite;
  final bool isSeen;
  final bool isInAnyList;
  final VoidCallback onWatchlistTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onSeenTap;
  final VoidCallback onAddToListTap;

  const ActionButtonsRow({
    super.key,
    required this.inWatchlist,
    required this.isFavorite,
    required this.isSeen,
    this.isInAnyList = false,
    required this.onWatchlistTap,
    required this.onFavoriteTap,
    required this.onSeenTap,
    required this.onAddToListTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Watchlist
          _ActionButton(
            icon: inWatchlist
                ? CupertinoIcons.bookmark_fill
                : CupertinoIcons.bookmark,
            label: l10n.detailWatchlist,
            isActive: inWatchlist,
            activeColor: colors.accent,
            onTap: onWatchlistTap,
          ),

          // Favorite
          _ActionButton(
            icon: isFavorite
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.heart,
            label: l10n.detailFavorite,
            isActive: isFavorite,
            activeColor: const Color(0xFFFF4D6D),
            onTap: onFavoriteTap,
          ),

          // Seen
          _ActionButton(
            icon: isSeen
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.checkmark_circle,
            label: l10n.detailSeen,
            isActive: isSeen,
            activeColor: colors.accent,
            onTap: onSeenTap,
          ),

          // Add to List
          _ActionButton(
            icon: isInAnyList
                ? CupertinoIcons.text_badge_checkmark
                : CupertinoIcons.text_badge_plus,
            label: l10n.strings.detailAddToList,
            isActive: isInAnyList,
            activeColor: colors.accent,
            onTap: onAddToListTap,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isActive
        ? (activeColor ?? colors.accent)
        : colors.textSecondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.15)
                    : colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.3)
                      : colors.surfaceBorder,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(height: 8),

            // Label
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: color,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para los action buttons
class ActionButtonsSkeleton extends StatelessWidget {
  const ActionButtonsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
