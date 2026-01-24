import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/kineon_colors.dart';
import 'kineon_button.dart';

/// Error state premium
///
/// Estilo Neo-cinema: elegante, no alarmante
class KineonErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;
  final ErrorSeverity severity;

  const KineonErrorState({
    super.key,
    this.title = 'Algo salió mal',
    this.message,
    this.actionLabel = 'Reintentar',
    this.onRetry,
    this.icon,
    this.compact = false,
    this.severity = ErrorSeverity.error,
  });

  /// Error de conexión
  factory KineonErrorState.network({VoidCallback? onRetry}) {
    return KineonErrorState(
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e intenta de nuevo',
      onRetry: onRetry,
      icon: AppIcons.globe,
      severity: ErrorSeverity.warning,
    );
  }

  /// Error de servidor
  factory KineonErrorState.server({VoidCallback? onRetry}) {
    return KineonErrorState(
      title: 'Error del servidor',
      message: 'Estamos teniendo problemas. Intenta más tarde.',
      onRetry: onRetry,
      severity: ErrorSeverity.error,
    );
  }

  /// Error de autenticación
  factory KineonErrorState.auth({VoidCallback? onLogin}) {
    return KineonErrorState(
      title: 'Sesión expirada',
      message: 'Inicia sesión para continuar',
      actionLabel: 'Iniciar sesión',
      onRetry: onLogin,
      icon: AppIcons.personOutline,
      severity: ErrorSeverity.info,
    );
  }

  /// Error de contenido no encontrado
  factory KineonErrorState.notFound({VoidCallback? onBack}) {
    return KineonErrorState(
      title: 'No encontrado',
      message: 'El contenido que buscas no existe o fue eliminado',
      actionLabel: 'Volver',
      onRetry: onBack,
      icon: AppIcons.search,
      severity: ErrorSeverity.warning,
    );
  }

  /// Error genérico con mensaje custom
  factory KineonErrorState.custom({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    return KineonErrorState(
      title: title,
      message: message,
      actionLabel: actionLabel,
      onRetry: onAction,
      icon: icon,
      severity: severity,
    );
  }

  Color _accentColor(KineonColors colors) {
    switch (severity) {
      case ErrorSeverity.error:
        return colors.error;
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.info:
        return colors.accent;
    }
  }

  IconData _getIcon(KineonColors colors) {
    if (icon != null) return icon!;
    switch (severity) {
      case ErrorSeverity.error:
        return AppIcons.error;
      case ErrorSeverity.warning:
        return AppIcons.warning;
      case ErrorSeverity.info:
        return AppIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (compact) {
      return _buildCompact(context, colors);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con animación
            _ErrorIcon(
              icon: _getIcon(colors),
              color: _accentColor(colors),
            ),

            const SizedBox(height: 28),

            // Título
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),

            // Mensaje
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Acción
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              KineonButton(
                label: actionLabel ?? 'Reintentar',
                icon: AppIcons.refresh,
                onPressed: onRetry,
                variant: KineonButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, KineonColors colors) {
    final accentColor = _accentColor(colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: AppRadii.radiusMd,
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(colors), size: 20, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h4.copyWith(color: accentColor),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            KineonIconButton(
              icon: AppIcons.refresh,
              onPressed: onRetry,
              size: 36,
              color: accentColor,
              backgroundColor: accentColor.withOpacity(0.1),
            ),
          ],
        ],
      ),
    );
  }
}

enum ErrorSeverity { error, warning, info }

/// Icono animado para error states
class _ErrorIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _ErrorIcon({
    required this.icon,
    required this.color,
  });

  @override
  State<_ErrorIcon> createState() => _ErrorIconState();
}

class _ErrorIconState extends State<_ErrorIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Ring
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // Icon
          Icon(
            widget.icon,
            size: 32,
            color: widget.color,
          ),
        ],
      ),
    );
  }
}

/// Snackbar/Toast de error compacto
class KineonErrorToast extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final ErrorSeverity severity;

  const KineonErrorToast({
    super.key,
    required this.message,
    this.onDismiss,
    this.severity = ErrorSeverity.error,
  });

  Color _getColor(KineonColors colors) {
    switch (severity) {
      case ErrorSeverity.error:
        return colors.error;
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.info:
        return colors.accent;
    }
  }

  IconData get _icon {
    switch (severity) {
      case ErrorSeverity.error:
        return AppIcons.error;
      case ErrorSeverity.warning:
        return AppIcons.warning;
      case ErrorSeverity.info:
        return AppIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _getColor(colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Icon(_icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                AppIcons.close,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
