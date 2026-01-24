import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/custom_list_repository.dart';
import 'create_list_modal.dart'; // For stringToIcon

/// Card para mostrar una lista personalizada con collage de posters
/// Diseño: collage 2x2 de posters + nombre + contador + botón "..."
class CustomListCard extends StatelessWidget {
  final CustomList list;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const CustomListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collage area - ocupa la mayor parte de la card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _PosterCollage(
                  previewItems: list.previewItems,
                  icon: list.icon,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Info area: nombre + botón "..."
          Row(
            children: [
              Expanded(
                child: Text(
                  list.name,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onMoreTap != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onMoreTap!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 2),

          // Item count
          Text(
            '${list.itemCount} ${list.itemCount == 1 ? 'item' : 'items'}',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for 2x2 poster collage - sin gaps entre posters
class _PosterCollage extends StatelessWidget {
  final List<ListPreviewItem> previewItems;
  final String icon;

  const _PosterCollage({
    required this.previewItems,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // If no items, show placeholder
    if (previewItems.isEmpty) {
      return _EmptyCollage(icon: icon);
    }

    // Build 2x2 grid seamless (sin gaps)
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPosterCell(context, 0)),
              Expanded(child: _buildPosterCell(context, 1)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPosterCell(context, 2)),
              Expanded(child: _buildPosterCell(context, 3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPosterCell(BuildContext context, int index) {
    final colors = context.colors;
    // Si no hay suficientes items, mostrar placeholder oscuro
    if (index >= previewItems.length) {
      return Container(
        color: colors.surface,
        child: Center(
          child: Icon(
            CupertinoIcons.film,
            color: colors.textTertiary.withValues(alpha: 0.2),
            size: 20,
          ),
        ),
      );
    }

    final item = previewItems[index];
    final posterUrl = item.posterUrl;

    if (posterUrl != null) {
      return CachedNetworkImage(
        imageUrl: posterUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: colors.surface,
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(colors),
      );
    }
    return _buildPlaceholder(colors);
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Container(
      color: colors.surface,
      child: Center(
        child: Icon(
          CupertinoIcons.film,
          color: colors.textTertiary.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }
}

/// Empty collage - muestra un placeholder con el icono de la lista
class _EmptyCollage extends StatelessWidget {
  final String icon;

  const _EmptyCollage({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surface,
      child: Center(
        child: Icon(
          stringToIcon(icon),
          color: colors.textTertiary.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }
}

/// Grid de listas personalizadas - 2 columnas
class CustomListsGrid extends StatelessWidget {
  final List<CustomList> lists;
  final void Function(CustomList) onListTap;
  final void Function(CustomList)? onListMoreTap;

  const CustomListsGrid({
    super.key,
    required this.lists,
    required this.onListTap,
    this.onListMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GridView.builder(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 160 + bottomPadding, // Extra space for FAB
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // Aspect ratio: collage cuadrado + espacio para texto
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return CustomListCard(
          list: list,
          onTap: () => onListTap(list),
          onMoreTap: onListMoreTap != null ? () => onListMoreTap!(list) : null,
        );
      },
    );
  }
}
