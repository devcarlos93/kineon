import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Tab de la biblioteca
enum LibraryTab {
  watchlist,
  favorites,
  watched,
  myLists,
}

/// Tabs de la biblioteca
class LibraryTabs extends StatelessWidget {
  final LibraryTab selectedTab;
  final ValueChanged<LibraryTab> onTabChanged;

  const LibraryTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    final tabs = [
      (LibraryTab.watchlist, l10n.strings.libraryWatchlist),
      (LibraryTab.favorites, l10n.strings.libraryFavorites),
      (LibraryTab.watched, l10n.strings.libraryWatched),
      (LibraryTab.myLists, l10n.strings.libraryMyLists),
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.map((tabData) {
          final tab = tabData.$1;
          final label = tabData.$2;
          final isSelected = selectedTab == tab;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onTabChanged(tab);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? colors.accent
                          : colors.surfaceBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textTertiary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Skeleton de tabs
class LibraryTabsSkeleton extends StatelessWidget {
  const LibraryTabsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 14,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
