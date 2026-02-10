import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/smart_collection.dart';

/// Card for a single smart collection in the horizontal list
class SmartCollectionCard extends StatelessWidget {
  final SmartCollection collection;
  final String locale;
  final VoidCallback? onTap;

  const SmartCollectionCard({
    super.key,
    required this.collection,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = collection.localizedTitle(locale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop image
              if (collection.backdropUrl != null)
                CachedNetworkImage(
                  imageUrl: collection.backdropUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: colors.surfaceElevated,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: colors.surfaceElevated,
                    child: Icon(
                      Icons.movie_outlined,
                      color: colors.textTertiary,
                      size: 40,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.accent.withValues(alpha: 0.3),
                        colors.accentPurple.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),

              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon badge
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        collection.iconData,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      title,
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Mini poster strip
                    SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          // Show first 4 posters
                          ...collection.items
                              .where((item) => item.posterUrl != null)
                              .take(4)
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: item.posterUrl!,
                                        width: 24,
                                        height: 36,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 24,
                                          height: 36,
                                          color: colors.surfaceElevated,
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 24,
                                          height: 36,
                                          color: colors.surfaceElevated,
                                        ),
                                      ),
                                    ),
                                  )),
                          const SizedBox(width: 4),
                          // Item count
                          Text(
                            '${collection.items.length}',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.movie_outlined,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.7),
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
      ),
    );
  }
}
