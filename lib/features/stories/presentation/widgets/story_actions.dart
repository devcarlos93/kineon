import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../home/domain/entities/media_item.dart';
import '../../../library/presentation/providers/library_providers.dart';

/// Botones de accion verticales al lado derecho (estilo TikTok)
class StoryActions extends ConsumerWidget {
  final MediaItem item;
  final VoidCallback onDetailsTap;

  const StoryActions({
    super.key,
    required this.item,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mediaState = ref.watch(mediaStateProvider(
      MediaStateParams(tmdbId: item.id, contentType: item.contentType),
    ));

    final state = mediaState.valueOrNull;
    final isInWatchlist = state.isInWatchlist;
    final isFavorite = state.isFavorite;

    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Watchlist
          _StoryActionButton(
            icon: isInWatchlist
                ? CupertinoIcons.bookmark_fill
                : CupertinoIcons.bookmark,
            label: l10n.detailWatchlist,
            isActive: isInWatchlist,
            activeColor: const Color(0xFF5EEAD4),
            onTap: () {
              HapticFeedback.lightImpact();
              if (isInWatchlist) {
                ref.read(libraryActionsProvider.notifier).removeFromWatchlist(
                      item.id,
                      item.contentType,
                    );
              } else {
                ref.read(libraryActionsProvider.notifier).addToWatchlist(
                      item.id,
                      item.contentType,
                    );
              }
            },
          ),

          const SizedBox(height: 20),

          // Favorite
          _StoryActionButton(
            icon: isFavorite
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.heart,
            label: l10n.detailFavorite,
            isActive: isFavorite,
            activeColor: const Color(0xFFFF4D6D),
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(libraryActionsProvider.notifier).toggleFavorite(
                    item.id,
                    item.contentType,
                  );
            },
          ),

          const SizedBox(height: 20),

          // Share
          _StoryActionButton(
            icon: CupertinoIcons.share,
            label: l10n.detailShare,
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              final type = item.isMovie ? 'movie' : 'tv';
              Share.share(
                '${item.title} - https://www.themoviedb.org/$type/${item.id}',
              );
            },
          ),

          const SizedBox(height: 20),

          // Details
          _StoryActionButton(
            icon: CupertinoIcons.info_circle,
            label: 'Info',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              onDetailsTap();
            },
          ),
        ],
      ),
    );
  }
}

class _StoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _StoryActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? Colors.white) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(blurRadius: 4, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
