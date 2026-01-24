import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

/// Skeleton loader para PosterCard
class SkeletonPosterCard extends StatelessWidget {
  final double width;
  final double aspectRatio;

  const SkeletonPosterCard({
    super.key,
    this.width = 140,
    this.aspectRatio = 0.67,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: AppColors.surfaceLight,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster skeleton
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Título skeleton
            Container(
              height: 14,
              width: width * 0.8,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            // Subtítulo skeleton
            Container(
              height: 10,
              width: width * 0.5,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader para FeaturedPosterCard
class SkeletonFeaturedCard extends StatelessWidget {
  const SkeletonFeaturedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Skeleton loader para QuickWatchCard
class SkeletonQuickWatchCard extends StatelessWidget {
  const SkeletonQuickWatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: AppColors.surfaceLight,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen skeleton
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Título skeleton
            Container(
              height: 14,
              width: 160,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            // Subtítulo skeleton
            Container(
              height: 10,
              width: 120,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para sección completa de carrusel
class SkeletonCarouselSection extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double aspectRatio;

  const SkeletonCarouselSection({
    super.key,
    this.itemCount = 5,
    this.itemWidth = 140,
    this.aspectRatio = 0.67,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Shimmer.fromColors(
            baseColor: colors.surfaceElevated,
            highlightColor: AppColors.surfaceLight,
            child: Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Cards skeleton
        SizedBox(
          height: itemWidth / aspectRatio + 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => SkeletonPosterCard(
              width: itemWidth,
              aspectRatio: aspectRatio,
            ),
          ),
        ),
      ],
    );
  }
}
