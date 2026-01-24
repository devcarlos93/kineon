import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Card de poster para carruseles
///
/// Muestra poster con overlay glass, título, género/año
/// y micro-dot lime si está en watchlist.
class PosterCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String subtitle;
  final bool inWatchlist;
  final bool isFavorite;
  final bool isWatched;
  final VoidCallback? onTap;
  final double? width;
  final double aspectRatio;

  const PosterCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.subtitle,
    this.inWatchlist = false,
    this.isFavorite = false,
    this.isWatched = false,
    this.onTap,
    this.width = 140,
    this.aspectRatio = 0.67,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster con overlay
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen
                      CachedNetworkImage(
                        imageUrl: posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colors.surfaceElevated,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.accent,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colors.surfaceElevated,
                          child: Icon(
                            Icons.movie_outlined,
                            color: colors.textTertiary,
                            size: 32,
                          ),
                        ),
                      ),

                      // Overlay glass sutil
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Status badges (arriba derecha)
                      if (isFavorite || inWatchlist)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Column(
                            children: [
                              if (isFavorite)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colors.error.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.error.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              if (isFavorite && inWatchlist)
                                const SizedBox(height: 4),
                              if (inWatchlist)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colors.accent.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.accent.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.bookmark,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Micro-dot verde lime (abajo derecha) - indica "Visto"
                      if (isWatched)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.accentLime,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.background,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.accentLime.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Título
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // Subtítulo (género • año)
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

    return GestureDetector(
      onTap: onTap,
      child: width != null ? SizedBox(width: width, child: content) : content,
    );
  }
}

/// Card de poster grande para "Para ti hoy"
class FeaturedPosterCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String aiReason;
  final bool inWatchlist;
  final VoidCallback? onTap;

  const FeaturedPosterCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.aiReason,
    this.inWatchlist = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colors.surfaceElevated,
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.surfaceElevated,
                  child: Icon(
                    Icons.movie_outlined,
                    color: colors.textTertiary,
                    size: 48,
                  ),
                ),
              ),

              // Overlay glass
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Badge "EN LISTA" si está en watchlist
              if (inWatchlist)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.accentLime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EN LISTA',
                          style: AppTypography.overline.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Contenido inferior
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aiReason,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.accent,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de cine rápido con duración
class QuickWatchCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String aiReason;
  final int runtime;
  final VoidCallback? onTap;

  const QuickWatchCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.aiReason,
    required this.runtime,
    this.onTap,
  });

  String get _formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con duración
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: colors.surfaceElevated,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: colors.surfaceElevated,
                          child: Icon(
                            Icons.movie_outlined,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),

                      // Badge duración
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formattedRuntime,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Título
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // Razón IA
            Text(
              aiReason,
              style: AppTypography.caption.copyWith(
                color: colors.accent,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
