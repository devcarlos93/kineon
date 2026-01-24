import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_movie_detail.dart';

/// Hero section del detalle con poster, backdrop y overlay glass
class DetailHero extends StatelessWidget {
  final MockMovieDetail movie;
  final VoidCallback? onBackTap;

  const DetailHero({
    super.key,
    required this.movie,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.55;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Backdrop image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: movie.backdropUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: colors.surfaceElevated,
              ),
              errorWidget: (context, url, error) => Container(
                color: colors.surfaceElevated,
                child: Icon(
                  CupertinoIcons.film,
                  size: 64,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.3),
                    colors.background.withValues(alpha: 0.85),
                    colors.background,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Back button con glass effect
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: _GlassButton(
              icon: CupertinoIcons.chevron_back,
              onTap: onBackTap ?? () => context.pop(),
            ),
          ),

          // Content at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Poster
                _PosterCard(posterUrl: movie.posterUrl),

                const SizedBox(width: 16),

                // Movie info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: AppTypography.h2.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Metadata row
                      _MetadataRow(movie: movie),

                      const SizedBox(height: 10),

                      // Genre pills
                      _GenrePills(genres: movie.genres),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Poster card con shadow y border radius
class _PosterCard extends StatelessWidget {
  final String posterUrl;

  const _PosterCard({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: posterUrl,
          fit: BoxFit.cover,
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Row con año, duración y rating
class _MetadataRow extends StatelessWidget {
  final MockMovieDetail movie;

  const _MetadataRow({required this.movie});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // Year
        Text(
          movie.year.toString(),
          style: AppTypography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),

        _Separator(),

        // Duration
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 14,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              movie.formattedRuntime,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),

        _Separator(),

        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.star_fill,
                size: 13,
                color: colors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                movie.rating.toStringAsFixed(1),
                style: AppTypography.labelMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: colors.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Pills de géneros
class _GenrePills extends StatelessWidget {
  final List<String> genres;

  const _GenrePills({required this.genres});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: genres.take(3).map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.surfaceBorder,
            ),
          ),
          child: Text(
            genre,
            style: AppTypography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Botón con efecto glass/blur
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.surfaceBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              icon,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
