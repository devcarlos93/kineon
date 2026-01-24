import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'library_tabs.dart';

/// Empty state genérico premium para biblioteca
class LibraryEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const LibraryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          bottom: 100 + bottomPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium illustration container
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.surface,
                    colors.surfaceElevated.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative sparkles
                  Positioned(
                    top: 30,
                    right: 40,
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: colors.accent.withValues(alpha: 0.3),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 35,
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: colors.accentPurple.withValues(alpha: 0.3),
                      size: 16,
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 50,
                    child: Icon(
                      CupertinoIcons.sparkles,
                      color: colors.accent.withValues(alpha: 0.2),
                      size: 14,
                    ),
                  ),
                  // Main icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.accent.withValues(alpha: 0.2),
                          colors.accentPurple.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      color: colors.accent,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),

              // Action button - full width premium
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onAction!();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      actionText!,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textOnAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state específico para Watchlist - Premium design
class WatchlistEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const WatchlistEmptyState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LibraryEmptyState(
      icon: CupertinoIcons.bookmark_fill,
      title: l10n.strings.libraryEmptyWatchlistTitle,
      subtitle: l10n.strings.libraryEmptyWatchlistSubtitle,
      actionText: l10n.strings.librarySaveFirstMovie,
      onAction: onExplore,
    );
  }
}

/// Empty state específico para Favoritos
class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const FavoritesEmptyState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LibraryEmptyState(
      icon: CupertinoIcons.heart,
      title: l10n.strings.libraryEmptyFavoritesTitle,
      subtitle: l10n.strings.libraryEmptyFavoritesSubtitle,
      actionText: l10n.strings.libraryDiscover,
      onAction: onExplore,
    );
  }
}

/// Empty state específico para Vistas
class WatchedEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const WatchedEmptyState({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LibraryEmptyState(
      icon: CupertinoIcons.eye,
      title: l10n.strings.libraryEmptyWatchedTitle,
      subtitle: l10n.strings.libraryEmptyWatchedSubtitle,
      actionText: l10n.strings.libraryStartWatching,
      onAction: onExplore,
    );
  }
}

/// Empty state específico para Mis Listas - Diseño personalizado
class MyListsEmptyState extends StatelessWidget {
  final VoidCallback? onCreate;

  const MyListsEmptyState({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          bottom: 100 + bottomPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom icon with decorative elements
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative dot top-right
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Decorative dot bottom-left
                  Positioned(
                    bottom: 20,
                    left: 15,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main icon container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.play_rectangle_fill,
                        color: colors.accent,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Crea tu primera lista',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Organiza películas por temas: Fin de semana, Con amigos, Oscuras...',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // CTA Button
            if (onCreate != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCreate!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(14),
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
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textOnAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Empty state para búsqueda sin resultados
class LibrarySearchEmptyState extends StatelessWidget {
  final String query;

  const LibrarySearchEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Icon(
                CupertinoIcons.search,
                color: colors.textTertiary,
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.strings.libraryNoResults,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                children: [
                  TextSpan(text: l10n.strings.libraryNoResultsFor),
                  TextSpan(
                    text: ' "$query"',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar el empty state correcto según el tab
class LibraryTabEmptyState extends StatelessWidget {
  final LibraryTab tab;
  final VoidCallback? onAction;

  const LibraryTabEmptyState({
    super.key,
    required this.tab,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case LibraryTab.watchlist:
        return WatchlistEmptyState(onExplore: onAction);
      case LibraryTab.favorites:
        return FavoritesEmptyState(onExplore: onAction);
      case LibraryTab.watched:
        return WatchedEmptyState(onExplore: onAction);
      case LibraryTab.myLists:
        return MyListsEmptyState(onCreate: onAction);
    }
  }
}
