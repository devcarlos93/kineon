import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Tipos de error predefinidos
enum ErrorStateType {
  network,
  server,
  notFound,
  unauthorized,
  timeout,
  maintenance,
  generic,
}

/// Severidad del error (afecta el estilo visual)
enum ErrorSeverity {
  warning,  // Amarillo - problemas menores
  error,    // Rojo - errores críticos
  info,     // Azul - informativos
}

/// Error State premium reutilizable con soporte multi-idioma
///
/// Uso básico:
/// ```dart
/// KineonErrorState(
///   type: ErrorStateType.network,
///   onRetry: () => ref.refresh(dataProvider),
/// )
/// ```
///
/// Uso personalizado:
/// ```dart
/// KineonErrorState.custom(
///   icon: CupertinoIcons.exclamationmark_triangle,
///   title: 'Error de pago',
///   message: 'No pudimos procesar tu tarjeta',
///   retryLabel: 'Reintentar pago',
///   onRetry: () {},
/// )
/// ```
class KineonErrorState extends StatelessWidget {
  final ErrorStateType? type;
  final IconData? customIcon;
  final String? customTitle;
  final String? customMessage;
  final String? customRetryLabel;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final ErrorSeverity severity;
  final bool compact;

  const KineonErrorState({
    super.key,
    this.type,
    this.customIcon,
    this.customTitle,
    this.customMessage,
    this.customRetryLabel,
    this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
    this.severity = ErrorSeverity.error,
    this.compact = false,
  });

  /// Constructor con tipos predefinidos
  factory KineonErrorState.fromType({
    Key? key,
    required ErrorStateType type,
    VoidCallback? onRetry,
    VoidCallback? onSecondary,
    bool compact = false,
  }) {
    return KineonErrorState(
      key: key,
      type: type,
      onRetry: onRetry,
      onSecondary: onSecondary,
      compact: compact,
    );
  }

  /// Constructor completamente personalizado
  factory KineonErrorState.custom({
    Key? key,
    required IconData icon,
    required String title,
    required String message,
    String? retryLabel,
    VoidCallback? onRetry,
    String? secondaryLabel,
    VoidCallback? onSecondary,
    ErrorSeverity severity = ErrorSeverity.error,
    bool compact = false,
  }) {
    return KineonErrorState(
      key: key,
      customIcon: icon,
      customTitle: title,
      customMessage: message,
      customRetryLabel: retryLabel,
      onRetry: onRetry,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      severity: severity,
      compact: compact,
    );
  }

  _ErrorStateConfig _getConfig(AppStrings strings) {
    // Si hay valores personalizados, usarlos
    if (customIcon != null && customTitle != null && customMessage != null) {
      return _ErrorStateConfig(
        icon: customIcon!,
        title: customTitle!,
        message: customMessage!,
        retryLabel: customRetryLabel,
        secondaryLabel: secondaryLabel,
        severity: severity,
      );
    }

    // Usar configuración según el tipo
    switch (type ?? ErrorStateType.generic) {
      case ErrorStateType.network:
        return _ErrorStateConfig(
          icon: CupertinoIcons.wifi_slash,
          title: strings.stateErrorNetworkTitle,
          message: strings.stateErrorNetworkMessage,
          retryLabel: strings.stateActionRetry,
          secondaryLabel: null,
          severity: ErrorSeverity.warning,
        );
      case ErrorStateType.server:
        return _ErrorStateConfig(
          icon: CupertinoIcons.exclamationmark_circle,
          title: strings.stateErrorServerTitle,
          message: strings.stateErrorServerMessage,
          retryLabel: strings.stateActionRetry,
          secondaryLabel: null,
          severity: ErrorSeverity.error,
        );
      case ErrorStateType.notFound:
        return _ErrorStateConfig(
          icon: CupertinoIcons.search,
          title: strings.stateErrorNotFoundTitle,
          message: strings.stateErrorNotFoundMessage,
          retryLabel: strings.stateActionBack,
          secondaryLabel: null,
          severity: ErrorSeverity.info,
        );
      case ErrorStateType.unauthorized:
        return _ErrorStateConfig(
          icon: CupertinoIcons.lock,
          title: strings.stateErrorUnauthorizedTitle,
          message: strings.stateErrorUnauthorizedMessage,
          retryLabel: strings.stateActionLogin,
          secondaryLabel: null,
          severity: ErrorSeverity.warning,
        );
      case ErrorStateType.timeout:
        return _ErrorStateConfig(
          icon: CupertinoIcons.clock,
          title: strings.stateErrorTimeoutTitle,
          message: strings.stateErrorTimeoutMessage,
          retryLabel: strings.stateActionRetry,
          secondaryLabel: null,
          severity: ErrorSeverity.warning,
        );
      case ErrorStateType.maintenance:
        return _ErrorStateConfig(
          icon: CupertinoIcons.hammer,
          title: strings.stateErrorMaintenanceTitle,
          message: strings.stateErrorMaintenanceMessage,
          retryLabel: strings.stateActionRefresh,
          secondaryLabel: null,
          severity: ErrorSeverity.info,
        );
      case ErrorStateType.generic:
        return _ErrorStateConfig(
          icon: CupertinoIcons.xmark_circle,
          title: strings.stateErrorGenericTitle,
          message: strings.stateErrorGenericMessage,
          retryLabel: strings.stateActionRetry,
          secondaryLabel: null,
          severity: ErrorSeverity.error,
        );
    }
  }

  Color _accentColor(KineonColors colors) {
    switch (severity) {
      case ErrorSeverity.warning:
        return const Color(0xFFF59E0B); // Amber
      case ErrorSeverity.error:
        return colors.error;
      case ErrorSeverity.info:
        return colors.accent;
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

  Widget _buildFull(_ErrorStateConfig config, KineonColors colors) {
    final accentColor = _accentColor(colors);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo
            _ErrorStateIcon(
              icon: config.icon,
              color: accentColor,
            ),

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

            // Mensaje
            Text(
              config.message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Botones
            if (config.retryLabel != null && onRetry != null)
              _ErrorStateCTA(
                label: config.retryLabel!,
                onTap: onRetry!,
                color: accentColor,
                colors: colors,
              ),

            if (config.secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 12),
              _ErrorStateSecondaryButton(
                label: config.secondaryLabel!,
                onTap: onSecondary!,
                colors: colors,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(_ErrorStateConfig config, KineonColors colors) {
    final accentColor = _accentColor(colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              config.icon,
              color: accentColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),

          if (config.retryLabel != null && onRetry != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.retryLabel!,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.textOnAccent,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Icono de error state
class _ErrorStateIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ErrorStateIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 36,
      ),
    );
  }
}

/// Botón CTA principal
class _ErrorStateCTA extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final KineonColors colors;

  const _ErrorStateCTA({
    required this.label,
    required this.onTap,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.arrow_clockwise,
              color: colors.textOnAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: colors.textOnAccent,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón secundario
class _ErrorStateSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final KineonColors colors;

  const _ErrorStateSecondaryButton({
    required this.label,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: colors.textSecondary,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Configuración interna para tipos predefinidos
class _ErrorStateConfig {
  final IconData icon;
  final String title;
  final String message;
  final String? retryLabel;
  final String? secondaryLabel;
  final ErrorSeverity severity;

  const _ErrorStateConfig({
    required this.icon,
    required this.title,
    required this.message,
    this.retryLabel,
    this.secondaryLabel,
    required this.severity,
  });
}
