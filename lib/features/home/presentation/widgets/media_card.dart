import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showRating;
  final bool showTitle;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    this.showRating = true,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.posterUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildPlaceholder(colors),
                            errorWidget: (context, url, error) =>
                                _buildErrorWidget(colors),
                          )
                        : _buildErrorWidget(colors),
                  ),
                ),

                // Badge de rating
                if (showRating)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor(item.voteAverage),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.ratingFormatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Badge de tipo (movie/tv)
                if (item.isTv)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Título y año
            if (showTitle) ...[
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.releaseYear != null)
                Text(
                  '${item.releaseYear}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(color: colors.surface),
    );
  }

  Widget _buildErrorWidget(KineonColors colors) {
    return Container(
      color: colors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 32, color: colors.textTertiary),
          const SizedBox(height: 4),
          Text(
            'Sin imagen',
            style: TextStyle(color: colors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7) return AppColors.ratingHigh;
    if (rating >= 5) return AppColors.ratingMedium;
    return AppColors.ratingLow;
  }
}
