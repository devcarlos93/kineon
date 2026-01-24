import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/custom_list_repository.dart';
import '../providers/custom_list_providers.dart';
import '../widgets/create_list_modal.dart';

/// Pantalla de detalle de una lista personalizada
class ListDetailScreen extends ConsumerStatefulWidget {
  final String listId;
  final String listName;
  final String listIcon;

  const ListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
    required this.listIcon,
  });

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final itemsAsync = ref.watch(listItemsWithDetailsProvider(widget.listId));

    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        backgroundColor: colors.background,
        navigationBar: CupertinoNavigationBar(
        backgroundColor: colors.background.withValues(alpha: 0.9),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Icon(
            CupertinoIcons.back,
            color: colors.textPrimary,
          ),
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              stringToIcon(widget.listIcon),
              color: colors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.listName,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showListOptions(),
          child: Icon(
            CupertinoIcons.ellipsis,
            color: colors.textSecondary,
          ),
        ),
      ),
      child: SafeArea(
        child: itemsAsync.when(
          loading: () => const Center(
            child: CupertinoActivityIndicator(),
          ),
          error: (error, _) {
            final l10n = AppLocalizations.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: colors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.strings.listDetailErrorLoading,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () => ref.invalidate(listItemsWithDetailsProvider(widget.listId)),
                    child: Text(l10n.strings.commonRetry),
                  ),
                ],
              ),
            );
          },
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState();
            }
            return _buildItemsGrid(items);
          },
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              stringToIcon(widget.listIcon),
              size: 64,
              color: colors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.strings.listDetailEmpty,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.strings.listDetailEmptySubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton(
              color: colors.accent,
              borderRadius: BorderRadius.circular(12),
              onPressed: () => context.go('/search'),
              child: Text(
                l10n.strings.listDetailExplore,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textOnAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(List<ListItemWithDetails> items) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 100 + bottomPadding,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ListItemCard(
          item: item,
          onTap: () => _navigateToDetail(item),
          onLongPress: () => _showItemOptions(item),
          onRemove: () => _removeFromList(item),
        );
      },
    );
  }

  void _navigateToDetail(ListItemWithDetails item) {
    HapticFeedback.lightImpact();
    final type = item.contentType == ContentType.movie ? 'movie' : 'tv';
    context.push('/details/$type/${item.tmdbId}');
  }

  void _showItemOptions(ListItemWithDetails item) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(item.title ?? l10n.strings.listDetailNoTitle),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToDetail(item);
            },
            child: Text(l10n.strings.listDetailViewDetails),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _removeFromList(item);
            },
            child: Text(l10n.strings.listDetailRemoveFromList),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.strings.commonCancel),
        ),
      ),
    );
  }

  void _removeFromList(ListItemWithDetails item) {
    ref.read(customListActionsProvider.notifier).removeItemFromList(
          widget.listId,
          item.tmdbId,
          item.contentType,
        );
  }

  void _showListOptions() {
    final l10n = AppLocalizations.of(context);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenameDialog();
            },
            child: Text(l10n.strings.libraryRenameList),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showDeleteConfirmation();
            },
            child: Text(l10n.strings.libraryDeleteList),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.strings.commonCancel),
        ),
      ),
    );
  }

  void _showRenameDialog() {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: widget.listName);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.strings.libraryRenameList),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: controller,
            placeholder: l10n.strings.libraryListNameHint,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.strings.commonCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != widget.listName) {
                await ref
                    .read(customListActionsProvider.notifier)
                    .updateList(widget.listId, name: newName);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) context.pop();
            },
            child: Text(l10n.strings.commonSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.strings.libraryDeleteList),
        content: Text(l10n.strings.libraryDeleteListConfirm(widget.listName)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.strings.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await ref.read(customListActionsProvider.notifier).deleteList(widget.listId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) context.pop();
            },
            child: Text(l10n.strings.commonDelete),
          ),
        ],
      ),
    );
  }
}

/// Card individual para item de la lista
class _ListItemCard extends StatelessWidget {
  final ListItemWithDetails item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;

  const _ListItemCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster con botón de eliminar
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
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
                            placeholder: (context, url) => Container(
                              color: colors.surfaceElevated,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildPlaceholder(colors),
                          )
                        : _buildPlaceholder(colors),
                  ),
                ),
                // Botón de eliminar
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRemove();
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.minus,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Título
          Text(
            item.title ?? AppLocalizations.of(context).strings.listDetailNoTitle,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Año
          if (item.releaseYear != null)
            Text(
              '${item.releaseYear}',
              style: AppTypography.caption.copyWith(
                color: colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Container(
      color: colors.surfaceElevated,
      child: Center(
        child: Icon(
          CupertinoIcons.film,
          color: colors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}
