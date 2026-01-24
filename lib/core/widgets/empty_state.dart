import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Tipos de empty state predefinidos
enum EmptyStateType {
  search,
  watchlist,
  favorites,
  watched,
  lists,
  notifications,
  downloads,
  history,
  generic,
}

/// Empty State premium reutilizable con soporte multi-idioma
///
/// Uso básico:
/// ```dart
/// KineonEmptyState(
///   type: EmptyStateType.watchlist,
///   onAction: () => context.go('/search'),
/// )
/// ```
///
/// Uso personalizado:
/// ```dart
/// KineonEmptyState.custom(
///   icon: CupertinoIcons.film,
///   title: 'Sin películas',
///   subtitle: 'Agrega películas a tu colección',
///   actionLabel: 'Explorar',
///   onAction: () {},
/// )
/// ```
class KineonEmptyState extends StatelessWidget {
  final EmptyStateType? type;
  final IconData? customIcon;
  final String? customTitle;
  final String? customSubtitle;
  final String? customActionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const KineonEmptyState({
    super.key,
    this.type,
    this.customIcon,
    this.customTitle,
    this.customSubtitle,
    this.customActionLabel,
    this.onAction,
    this.compact = false,
  });

  /// Constructor con tipos predefinidos
  factory KineonEmptyState.fromType({
    Key? key,
    required EmptyStateType type,
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return KineonEmptyState(
      key: key,
      type: type,
      onAction: onAction,
      compact: compact,
    );
  }

  /// Constructor completamente personalizado
  factory KineonEmptyState.custom({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return KineonEmptyState(
      key: key,
      customIcon: icon,
      customTitle: title,
      customSubtitle: subtitle,
      customActionLabel: actionLabel,
      onAction: onAction,
      compact: compact,
    );
  }

  _EmptyStateConfig _getConfig(AppStrings strings) {
    // Si hay valores personalizados, usarlos
    if (customIcon != null && customTitle != null && customSubtitle != null) {
      return _EmptyStateConfig(
        icon: customIcon!,
        title: customTitle!,
        subtitle: customSubtitle!,
        actionLabel: customActionLabel,
      );
    }

    // Usar configuración según el tipo
    switch (type ?? EmptyStateType.generic) {
      case EmptyStateType.search:
        return _EmptyStateConfig(
          icon: CupertinoIcons.search,
          title: strings.stateEmptySearchTitle,
          subtitle: strings.stateEmptySearchSubtitle,
          actionLabel: strings.stateEmptySearchAction,
        );
      case EmptyStateType.watchlist:
        return _EmptyStateConfig(
          icon: CupertinoIcons.bookmark,
          title: strings.stateEmptyWatchlistTitle,
          subtitle: strings.stateEmptyWatchlistSubtitle,
          actionLabel: strings.stateEmptyWatchlistAction,
        );
      case EmptyStateType.favorites:
        return _EmptyStateConfig(
          icon: CupertinoIcons.heart,
          title: strings.stateEmptyFavoritesTitle,
          subtitle: strings.stateEmptyFavoritesSubtitle,
          actionLabel: strings.stateEmptyFavoritesAction,
        );
      case EmptyStateType.watched:
        return _EmptyStateConfig(
          icon: CupertinoIcons.eye,
          title: strings.stateEmptyWatchedTitle,
          subtitle: strings.stateEmptyWatchedSubtitle,
          actionLabel: strings.stateEmptyWatchedAction,
        );
      case EmptyStateType.lists:
        return _EmptyStateConfig(
          icon: CupertinoIcons.square_list,
          title: strings.stateEmptyListsTitle,
          subtitle: strings.stateEmptyListsSubtitle,
          actionLabel: strings.stateEmptyListsAction,
        );
      case EmptyStateType.notifications:
        return _EmptyStateConfig(
          icon: CupertinoIcons.bell,
          title: strings.stateEmptyNotificationsTitle,
          subtitle: strings.stateEmptyNotificationsSubtitle,
          actionLabel: null,
        );
      case EmptyStateType.downloads:
        return _EmptyStateConfig(
          icon: CupertinoIcons.cloud_download,
          title: strings.stateEmptyDownloadsTitle,
          subtitle: strings.stateEmptyDownloadsSubtitle,
          actionLabel: strings.stateEmptyDownloadsAction,
        );
      case EmptyStateType.history:
        return _EmptyStateConfig(
          icon: CupertinoIcons.clock,
          title: strings.stateEmptyHistoryTitle,
          subtitle: strings.stateEmptyHistorySubtitle,
          actionLabel: null,
        );
      case EmptyStateType.generic:
        return _EmptyStateConfig(
          icon: CupertinoIcons.tray,
          title: strings.stateEmptyGenericTitle,
          subtitle: strings.stateEmptyGenericSubtitle,
          actionLabel: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppLocalizations.of(context).strings;
    final config = _getConfig(strings);

    if (compact) {
      return _buildCompact(config, colors);
    }
    return _buildFull(config, colors);
  }

  Widget _buildFull(_EmptyStateConfig config, KineonColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo gradiente
            _EmptyStateIcon(icon: config.icon, colors: colors),

            const SizedBox(height: 24),

            // Título
            Text(
              config.title,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              config.subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),

            if (config.actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),

              // CTA Button
              _EmptyStateCTA(
                label: config.actionLabel!,
                onTap: onAction!,
                colors: colors,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(_EmptyStateConfig config, KineonColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Row(
        children: [
          // Icono pequeño
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              color: colors.textTertiary,
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),

          if (config.actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            _EmptyStateCTASmall(
              label: config.actionLabel!,
              onTap: onAction!,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

/// Icono de empty state con fondo gradiente
class _EmptyStateIcon extends StatelessWidget {
  final IconData icon;
  final KineonColors colors;

  const _EmptyStateIcon({required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.accentPurple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: colors.textTertiary,
        size: 36,
      ),
    );
  }
}

/// Botón CTA de empty state
class _EmptyStateCTA extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final KineonColors colors;

  const _EmptyStateCTA({
    required this.label,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: colors.textOnAccent,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Botón CTA pequeño para versión compacta
class _EmptyStateCTASmall extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final KineonColors colors;

  const _EmptyStateCTASmall({
    required this.label,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Configuración interna para tipos predefinidos
class _EmptyStateConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;

  const _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
  });
}
