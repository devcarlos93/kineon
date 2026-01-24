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
import '../providers/library_providers.dart';
import '../widgets/create_list_modal.dart';
import '../widgets/custom_list_card.dart';
import '../widgets/library_empty_states.dart';
import '../widgets/library_header.dart';
import '../widgets/library_tabs.dart';
import '../widgets/list_limit_modal.dart';
import '../widgets/viewing_heatmap.dart';

/// Pantalla de biblioteca con datos reales de Supabase
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryTab _selectedTab = LibraryTab.watchlist;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDetail(int tmdbId, ContentType contentType) {
    final type = contentType == ContentType.movie ? 'movie' : 'tv';
    context.push('/details/$type/$tmdbId');
  }

  void _showItemOptions(LibraryItemWithDetails item) {
    final contentType = item.contentType;
    final tmdbId = item.tmdbId;
    final title = item.title ?? 'Item';

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(libraryActionsProvider.notifier).toggleFavorite(
                    tmdbId,
                    contentType,
                  );
            },
            child: Text(
              item.isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
            ),
          ),
          if (!item.isInWatchlist)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(libraryActionsProvider.notifier).addToWatchlist(
                      tmdbId,
                      contentType,
                    );
              },
              child: const Text('Añadir a watchlist'),
            ),
          if (item.isInWatchlist)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(libraryActionsProvider.notifier).removeFromWatchlist(
                      tmdbId,
                      contentType,
                    );
              },
              child: const Text('Quitar de watchlist'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              if (item.isWatched) {
                ref.read(libraryActionsProvider.notifier).removeFromWatched(
                      tmdbId,
                      contentType,
                    );
              } else {
                ref.read(libraryActionsProvider.notifier).markAsWatched(
                      tmdbId,
                      contentType,
                    );
              }
            },
            child: Text(
              item.isWatched ? 'Marcar como no visto' : 'Marcar como visto',
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(libraryActionsProvider.notifier).delete(
                    tmdbId,
                    contentType,
                  );
            },
            child: const Text('Eliminar de biblioteca'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    final activityAsync = ref.watch(viewingActivityProvider);

    return activityAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: ViewingHeatmapSkeleton(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (activity) {
        // Solo mostrar si hay actividad
        if (activity.totalWatched == 0) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ViewingHeatmap(
            data: activity,
            onTap: () {
              // TODO: Mostrar estadísticas detalladas
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Header or Search bar
          if (_isSearching)
            LibrarySearchBar(
              controller: _searchController,
              onClose: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            )
          else
            LibraryHeader(
              onSearchTap: () {
                setState(() => _isSearching = true);
              },
            ),

          // Heatmap de actividad (comentado temporalmente - causa overflow en empty state)
          // TODO: Reactivar cuando se implemente scroll o se ajuste el layout
          // if (!_isSearching) _buildHeatmap(),

          const SizedBox(height: 8),

          // Tabs
          LibraryTabs(
            selectedTab: _selectedTab,
            onTabChanged: (tab) {
              setState(() => _selectedTab = tab);
            },
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateListModal() async {
    // Verificar límite antes de mostrar modal
    final limitCheck = await ref.read(customListActionsProvider.notifier).canCreateList();

    if (!limitCheck.allowed && mounted) {
      ListLimitModal.show(
        context,
        reason: limitCheck.reason!,
        current: limitCheck.current,
        limit: limitCheck.limit,
      );
      return;
    }

    if (!mounted) return;

    CreateListModal.show(
      context,
      onCreate: (name, icon) {
        ref.read(customListActionsProvider.notifier).createList(name, icon);
      },
    );
  }

  void _showListOptions(CustomList list) {
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(list.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenameListModal(list);
            },
            child: Text(l10n.strings.libraryRenameList),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _showDeleteConfirmation(list);
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

  void _showRenameListModal(CustomList list) {
    final controller = TextEditingController(text: list.name);
    final l10n = AppLocalizations.of(context);

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
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != list.name) {
                ref
                    .read(customListActionsProvider.notifier)
                    .updateList(list.id, name: newName);
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.strings.commonSave),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(CustomList list) {
    final l10n = AppLocalizations.of(context);

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.strings.libraryDeleteList),
        content: Text(l10n.strings.libraryDeleteListConfirm(list.name)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.strings.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(customListActionsProvider.notifier).deleteList(list.id);
              Navigator.pop(ctx);
            },
            child: Text(l10n.strings.commonDelete),
          ),
        ],
      ),
    );
  }

  void _onListTap(CustomList list) {
    HapticFeedback.lightImpact();
    final encodedName = Uri.encodeComponent(list.name);
    final encodedIcon = Uri.encodeComponent(list.icon);
    context.push('/library/list/${list.id}?name=$encodedName&icon=$encodedIcon');
  }

  Widget _buildMyListsTab() {
    final colors = context.colors;
    final listsAsync = ref.watch(customListsProvider);

    return listsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.accent),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar listas',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(customListsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (lists) {
        if (lists.isEmpty) {
          return MyListsEmptyState(onCreate: _showCreateListModal);
        }

        return Stack(
          children: [
            // Grid de listas
            CustomListsGrid(
              lists: lists,
              onListTap: _onListTap,
              onListMoreTap: _showListOptions,
            ),

            // FAB para crear nueva lista
            Positioned(
              bottom: 100 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Center(
                child: _CreateListFAB(onTap: _showCreateListModal),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    final colors = context.colors;
    // My Lists tab - funcionalidad real
    if (_selectedTab == LibraryTab.myLists) {
      return _buildMyListsTab();
    }

    // Seleccionar el provider correcto según la pestaña
    final AsyncValue<List<LibraryItemWithDetails>> itemsAsync;
    switch (_selectedTab) {
      case LibraryTab.watchlist:
        itemsAsync = ref.watch(watchlistWithDetailsProvider);
      case LibraryTab.favorites:
        itemsAsync = ref.watch(favoritesWithDetailsProvider);
      case LibraryTab.watched:
        itemsAsync = ref.watch(watchedWithDetailsProvider);
      case LibraryTab.myLists:
        return const SizedBox.shrink();
    }

    return itemsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.accent),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(watchlistWithDetailsProvider);
                ref.invalidate(favoritesWithDetailsProvider);
                ref.invalidate(watchedWithDetailsProvider);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (items) {
        // Filtrar por búsqueda
        final filteredItems = _searchQuery.isEmpty
            ? items
            : items.where((item) {
                final title = item.title ?? '';
                return title.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

        // Empty state
        if (filteredItems.isEmpty) {
          if (_searchQuery.isNotEmpty) {
            return LibrarySearchEmptyState(query: _searchQuery);
          }
          return LibraryTabEmptyState(
            tab: _selectedTab,
            onAction: () {
              // Navegar a búsqueda
              context.go('/search');
            },
          );
        }

        // Grid de items
        return _LibraryGrid(
          items: filteredItems,
          onItemTap: (item) {
            HapticFeedback.lightImpact();
            _navigateToDetail(item.tmdbId, item.contentType);
          },
          onItemLongPress: (item) {
            HapticFeedback.mediumImpact();
            _showItemOptions(item);
          },
        );
      },
    );
  }
}

/// Grid de items de biblioteca
class _LibraryGrid extends StatelessWidget {
  final List<LibraryItemWithDetails> items;
  final void Function(LibraryItemWithDetails) onItemTap;
  final void Function(LibraryItemWithDetails) onItemLongPress;

  const _LibraryGrid({
    required this.items,
    required this.onItemTap,
    required this.onItemLongPress,
  });

  @override
  Widget build(BuildContext context) {
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
        return _LibraryGridItem(
          item: item,
          onTap: () => onItemTap(item),
          onLongPress: () => onItemLongPress(item),
        );
      },
    );
  }
}

/// Item individual del grid
class _LibraryGridItem extends StatelessWidget {
  final LibraryItemWithDetails item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LibraryGridItem({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final posterUrl = item.posterUrl;
    final title = item.title ?? 'Sin título';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: Container(
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen
                    if (posterUrl != null)
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
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(colors),
                      )
                    else
                      _buildPlaceholder(colors),

                    // Badges
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Column(
                        children: [
                          if (item.isFavorite)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.error.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Micro-dot visto
                    if (item.isWatched)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.accentLime,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.background,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentLime.withValues(alpha: 0.5),
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

          const SizedBox(height: 8),

          // Título
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtítulo
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
          Icons.movie_outlined,
          color: colors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}

/// FAB para crear nueva lista - Pill button centrado
class _CreateListFAB extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateListFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.plus,
              color: AppColors.textOnAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Nueva lista',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textOnAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
