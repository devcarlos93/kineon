import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_library_data.dart';
import '../widgets/create_list_modal.dart';
import '../widgets/library_card.dart';
import '../widgets/library_empty_states.dart';
import '../widgets/library_header.dart';
import '../widgets/library_tabs.dart';
// import '../widgets/viewing_heatmap.dart'; // Usar LibraryScreen para datos reales

/// Pantalla de biblioteca con mock data y diseño Stitch
class LibraryMockScreen extends StatefulWidget {
  const LibraryMockScreen({super.key});

  @override
  State<LibraryMockScreen> createState() => _LibraryMockScreenState();
}

class _LibraryMockScreenState extends State<LibraryMockScreen> {
  LibraryTab _selectedTab = LibraryTab.watchlist;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data
  List<LibraryItem> _watchlist = List.from(mockWatchlistItems);
  List<LibraryItem> _favorites = List.from(mockFavoritesItems);
  List<LibraryItem> _watched = List.from(mockWatchedItems);
  List<UserList> _userLists = List.from(mockUserLists);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryItem> get _currentItems {
    List<LibraryItem> items;
    switch (_selectedTab) {
      case LibraryTab.watchlist:
        items = _watchlist;
      case LibraryTab.favorites:
        items = _favorites;
      case LibraryTab.watched:
        items = _watched;
      case LibraryTab.myLists:
        return []; // My lists uses different widget
    }

    if (_searchQuery.isEmpty) return items;

    return items
        .where((item) =>
            item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _handleItemTap(LibraryItem item) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to movie detail
  }

  void _handleItemLongPress(LibraryItem item) {
    HapticFeedback.mediumImpact();
    _showItemOptions(item);
  }

  void _showItemOptions(LibraryItem item) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(item.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _toggleFavorite(item);
            },
            child: Text(
              item.isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _toggleWatchlist(item);
            },
            child: Text(
              item.isInWatchlist ? 'Quitar de watchlist' : 'Añadir a watchlist',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _toggleWatched(item);
            },
            child: Text(
              item.isWatched ? 'Marcar como no visto' : 'Marcar como visto',
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _removeItem(item);
            },
            child: const Text('Eliminar'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _toggleFavorite(LibraryItem item) {
    setState(() {
      if (item.isFavorite) {
        _favorites.removeWhere((i) => i.id == item.id);
      } else {
        _favorites.add(item.copyWith(isFavorite: true));
      }
    });
  }

  void _toggleWatchlist(LibraryItem item) {
    setState(() {
      if (item.isInWatchlist) {
        _watchlist.removeWhere((i) => i.id == item.id);
      } else {
        _watchlist.add(item.copyWith(isInWatchlist: true));
      }
    });
  }

  void _toggleWatched(LibraryItem item) {
    setState(() {
      if (item.isWatched) {
        _watched.removeWhere((i) => i.id == item.id);
      } else {
        _watched.add(item.copyWith(isWatched: true, watchedAt: DateTime.now()));
      }
    });
  }

  void _removeItem(LibraryItem item) {
    setState(() {
      _watchlist.removeWhere((i) => i.id == item.id);
      _favorites.removeWhere((i) => i.id == item.id);
      _watched.removeWhere((i) => i.id == item.id);
    });
  }

  void _handleListTap(UserList list) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to list detail
  }

  void _handleCreateList() {
    CreateListModal.show(
      context,
      onCreate: (name, icon) {
        setState(() {
          _userLists.add(UserList(
            id: 'list-${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            icon: icon,
            items: [],
            createdAt: DateTime.now(),
          ));
        });
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

          // Heatmap comentado - usar LibraryScreen para datos reales
          // if (!_isSearching) ...[
          //   ViewingHeatmap(data: ...),
          //   const SizedBox(height: 20),
          // ],
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

  Widget _buildContent() {
    final colors = context.colors;
    // My Lists tab - uses real implementation now
    if (_selectedTab == LibraryTab.myLists) {
      if (_userLists.isEmpty) {
        return MyListsEmptyState(onCreate: _handleCreateList);
      }
      return _buildMockListsSection();
    }

    final items = _currentItems;

    // Search with no results
    if (_searchQuery.isNotEmpty && items.isEmpty) {
      return LibrarySearchEmptyState(query: _searchQuery);
    }

    // Empty state
    if (items.isEmpty) {
      return LibraryTabEmptyState(
        tab: _selectedTab,
        onAction: () {
          // TODO: Navigate to discover/search
        },
      );
    }

    // Grid of items
    return LibraryGrid(
      items: items,
      onItemTap: _handleItemTap,
      onItemLongPress: _handleItemLongPress,
    );
  }

  /// Simple mock lists section for demo purposes
  Widget _buildMockListsSection() {
    final colors = context.colors;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _userLists.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Create new list button
          return GestureDetector(
            onTap: _handleCreateList,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.plus,
                      color: AppColors.textOnAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Crear nueva lista',
                    style: AppTypography.labelLarge.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final list = _userLists[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(list.icon, style: const TextStyle(fontSize: 24)), // Mock uses emojis
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${list.items.length} items',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: colors.textTertiary,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Floating Action Button para crear lista
class LibraryFAB extends StatelessWidget {
  final VoidCallback onTap;

  const LibraryFAB({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Positioned(
      right: 20,
      bottom: 100,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.plus,
            color: AppColors.textOnAccent,
            size: 28,
          ),
        ),
      ),
    );
  }
}
