import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/kineon_colors.dart';

/// Skeleton loader con shimmer effect
///
/// Estilo Neo-cinema: shimmer sutil y elegante
class KineonSkeleton extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const KineonSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: colors.surface.withOpacity(0.5),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Box skeleton para contenedores
class KineonSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const KineonSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: colors.textPrimary.withOpacity(0.05),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: borderRadius ?? AppRadii.radiusMd,
        ),
      ),
    );
  }
}

/// Text skeleton para líneas de texto
class KineonSkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const KineonSkeletonText({
    super.key,
    this.width = 100,
    this.height = 14,
    this.borderRadius,
  });

  /// Skeleton para título
  factory KineonSkeletonText.title({double width = 180}) {
    return KineonSkeletonText(width: width, height: 20);
  }

  /// Skeleton para subtítulo
  factory KineonSkeletonText.subtitle({double width = 120}) {
    return KineonSkeletonText(width: width, height: 14);
  }

  /// Skeleton para caption
  factory KineonSkeletonText.caption({double width = 80}) {
    return KineonSkeletonText(width: width, height: 12);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: colors.textPrimary.withOpacity(0.05),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: borderRadius ?? AppRadii.radiusXs,
        ),
      ),
    );
  }
}

/// Skeleton para poster de película
class KineonSkeletonPoster extends StatelessWidget {
  final double width;
  final double? height;
  final double aspectRatio;
  final bool showTitle;

  const KineonSkeletonPoster({
    super.key,
    this.width = 120,
    this.height,
    this.aspectRatio = 2 / 3,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final posterHeight = height ?? width / aspectRatio;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KineonSkeletonBox(
            width: width,
            height: posterHeight,
            borderRadius: AppRadii.radiusMd,
          ),
          if (showTitle) ...[
            const SizedBox(height: 10),
            KineonSkeletonText(width: width * 0.85, height: 14),
            const SizedBox(height: 6),
            KineonSkeletonText(width: width * 0.5, height: 12),
          ],
        ],
      ),
    );
  }
}

/// Skeleton para lista horizontal de posters
class KineonSkeletonCarousel extends StatelessWidget {
  final int itemCount;
  final double posterWidth;
  final double spacing;
  final bool showTitle;
  final EdgeInsetsGeometry? padding;

  const KineonSkeletonCarousel({
    super.key,
    this.itemCount = 5,
    this.posterWidth = 120,
    this.spacing = 12,
    this.showTitle = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showTitle
          ? posterWidth / (2 / 3) + 50
          : posterWidth / (2 / 3),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) => KineonSkeletonPoster(
          width: posterWidth,
          showTitle: showTitle,
        ),
      ),
    );
  }
}

/// Skeleton para card de contenido
class KineonSkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const KineonSkeletonCard({
    super.key,
    this.width,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.radiusLg,
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Thumbnail
          KineonSkeletonBox(
            width: height - 24,
            height: height - 24,
            borderRadius: AppRadii.radiusSm,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KineonSkeletonText.title(width: double.infinity),
                const SizedBox(height: 8),
                KineonSkeletonText.subtitle(width: 150),
                const SizedBox(height: 8),
                KineonSkeletonText.caption(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para sección completa (título + contenido)
class KineonSkeletonSection extends StatelessWidget {
  final Widget content;
  final double titleWidth;

  const KineonSkeletonSection({
    super.key,
    required this.content,
    this.titleWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: KineonSkeletonText.title(width: titleWidth),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
}

/// Skeleton circular para avatares
class KineonSkeletonAvatar extends StatelessWidget {
  final double size;

  const KineonSkeletonAvatar({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer.fromColors(
      baseColor: colors.surfaceElevated,
      highlightColor: colors.textPrimary.withOpacity(0.05),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
