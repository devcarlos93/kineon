import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_icons.dart';
import '../theme/kineon_colors.dart';
import 'kineon_button.dart';

/// Empty state premium para listas vacías
///
/// Estilo Neo-cinema: ilustración mínima, texto elegante
class KineonEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final bool compact;

  const KineonEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.customIcon,
    this.compact = false,
  });

  /// Empty state para búsqueda sin resultados
  factory KineonEmptyState.noResults({
    String query = '',
    VoidCallback? onClear,
  }) {
    return KineonEmptyState(
      icon: AppIcons.search,
      title: 'Sin resultados',
      message: query.isNotEmpty
          ? 'No encontramos nada para "$query"'
          : 'No hay resultados para tu búsqueda',
      actionLabel: onClear != null ? 'Limpiar búsqueda' : null,
      onAction: onClear,
    );
  }

  /// Empty state para watchlist vacía
  factory KineonEmptyState.watchlist({VoidCallback? onBrowse}) {
    return KineonEmptyState(
      icon: AppIcons.bookmarkOutline,
      title: 'Tu watchlist está vacía',
      message: 'Agrega películas y series que quieras ver más tarde',
      actionLabel: 'Explorar contenido',
      onAction: onBrowse,
    );
  }

  /// Empty state para favoritos vacíos
  factory KineonEmptyState.favorites({VoidCallback? onBrowse}) {
    return KineonEmptyState(
      icon: AppIcons.heartOutline,
      title: 'Sin favoritos',
      message: 'Marca tus películas y series favoritas',
      actionLabel: 'Descubrir',
      onAction: onBrowse,
    );
  }

  /// Empty state para historial vacío
  factory KineonEmptyState.history({VoidCallback? onBrowse}) {
    return KineonEmptyState(
      icon: AppIcons.clock,
      title: 'Sin historial',
      message: 'Las películas y series que veas aparecerán aquí',
      actionLabel: 'Empezar a ver',
      onAction: onBrowse,
    );
  }

  /// Empty state para listas personalizadas vacías
  factory KineonEmptyState.customList({VoidCallback? onAdd}) {
    return KineonEmptyState(
      icon: AppIcons.folderOutline,
      title: 'Lista vacía',
      message: 'Agrega películas y series a esta lista',
      actionLabel: 'Agregar contenido',
      onAction: onAdd,
    );
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
            // Icono decorativo
            _buildIconContainer(colors: colors),

            SizedBox(height: compact ? 16 : 28),

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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              KineonButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: KineonButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, KineonColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Row(
        children: [
          _buildIconContainer(size: 56, colors: colors),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h3),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            KineonTextButton(
              label: actionLabel!,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconContainer({double size = 80, required KineonColors colors}) {
    return customIcon ?? Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accentPurple.withOpacity(0.15),
            colors.accent.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.45,
        color: colors.accent.withOpacity(0.8),
      ),
    );
  }
}

/// Ilustración animada para empty states premium
class KineonEmptyIllustration extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const KineonEmptyIllustration({
    super.key,
    required this.icon,
    this.color,
    this.size = 100,
  });

  @override
  State<KineonEmptyIllustration> createState() => _KineonEmptyIllustrationState();
}

class _KineonEmptyIllustrationState extends State<KineonEmptyIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
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
    final colors = context.colors;
    final color = widget.color ?? colors.accent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow background
          Container(
            width: widget.size * 1.5,
            height: widget.size * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Ring
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
          ),
          // Icon
          Icon(
            widget.icon,
            size: widget.size * 0.5,
            color: color.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}

/// Placeholder para cuando no hay datos pero no es un "empty state" completo
class KineonPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;

  const KineonPlaceholder({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
