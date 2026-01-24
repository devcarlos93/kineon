import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/media_item.dart';
import 'media_card.dart';

class MediaCarousel extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final void Function(MediaItem) onTap;
  final VoidCallback? onSeeAll;

  const MediaCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todo',
                        style: TextStyle(color: colors.accent),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: colors.accent,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Lista horizontal
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: MediaCard(
                  item: items[index],
                  onTap: () => onTap(items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
