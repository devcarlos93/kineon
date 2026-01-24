import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../library/data/repositories/library_repository.dart';
import '../../domain/entities/media_item.dart';
import 'poster_card.dart';
import 'skeleton_card.dart';

/// Carrusel horizontal reutilizable
///
/// Muestra título con "Ver todo" opcional y lista horizontal
/// de PosterCards.
class HorizontalCarousel extends StatelessWidget {
  final String title;
  final String? badge;
  final List<MediaItem> items;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final Function(MediaItem)? onItemTap;
  /// Mapa de estados de biblioteca: tmdbId -> MediaState
  final Map<int, MediaState>? mediaStates;

  const HorizontalCarousel({
    super.key,
    required this.title,
    this.badge,
    required this.items,
    this.isLoading = false,
    this.onSeeAll,
    this.onItemTap,
    this.mediaStates,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título y "Ver todo"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.overline.copyWith(
                          color: colors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'Ver todo',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista horizontal
        if (isLoading)
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SkeletonPosterCard(),
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final state = mediaStates?[item.id];
                return PosterCard(
                  title: item.title,
                  posterUrl: item.posterUrl ?? '',
                  subtitle: item.releaseYear != null
                      ? '${item.ratingFormatted} • ${item.releaseYear}'
                      : item.ratingFormatted,
                  inWatchlist: state?.isInWatchlist ?? false,
                  isFavorite: state?.isFavorite ?? false,
                  isWatched: state?.isWatched ?? false,
                  onTap: () => onItemTap?.call(item),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Carrusel para "Cine rápido" con duración
class QuickWatchCarousel extends StatelessWidget {
  final String title;
  final String? badge;
  final List<MediaItem> items;
  final bool isLoading;
  final Function(MediaItem)? onItemTap;

  const QuickWatchCarousel({
    super.key,
    required this.title,
    this.badge,
    required this.items,
    this.isLoading = false,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.surfaceBorder,
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.overline.copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista horizontal
        if (isLoading)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SkeletonQuickWatchCard(),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return QuickWatchCard(
                  title: item.title,
                  imageUrl: item.posterUrl ?? '',
                  aiReason: item.overview ?? '',
                  runtime: 90, // TODO: obtener runtime de detalles
                  onTap: () => onItemTap?.call(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
