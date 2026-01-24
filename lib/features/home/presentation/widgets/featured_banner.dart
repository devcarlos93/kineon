import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/media_item.dart';

class FeaturedBanner extends StatelessWidget {
  final MediaItem item;

  const FeaturedBanner({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        final type = item.isMovie ? 'movie' : 'tv';
        context.push('/details/$type/${item.id}');
      },
      child: SizedBox(
        height: size.height * 0.55,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            if (item.backdropUrl != null)
              CachedNetworkImage(
                imageUrl: item.backdropUrlLarge ?? item.backdropUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: colors.surface),
                errorWidget: (context, url, error) => Container(
                  color: colors.surface,
                  child: const Icon(Icons.movie, size: 64),
                ),
              ),

            // Gradiente inferior
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    colors.background.withOpacity(0.8),
                    colors.background,
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),

            // Gradiente superior (para el app bar)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    colors.background.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Contenido
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DESTACADO',
                      style: TextStyle(
                        color: colors.textOnAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Info
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRatingColor(
                            item.voteAverage,
                          ).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.ratingFormatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Año
                      if (item.releaseYear != null)
                        Text(
                          '${item.releaseYear}',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Descripción
                  if (item.overview != null && item.overview!.isNotEmpty)
                    Text(
                      item.overview!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 16),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final type = item.isMovie ? 'movie' : 'tv';
                            context.push('/details/$type/${item.id}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.textOnAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text('Ver detalles'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Agregar a lista
                          },
                          icon: const Icon(Icons.add),
                          tooltip: 'Agregar a mi lista',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 7) return AppColors.accentLime;
    if (rating >= 5) return AppColors.warning;
    return AppColors.error;
  }
}
