import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import '../theme/kineon_colors.dart';

/// Variantes de botón Kineon
enum KineonButtonVariant {
  /// Botón principal con gradiente
  primary,
  /// Botón secundario con outline
  secondary,
  /// Botón terciario (ghost)
  tertiary,
  /// Botón de peligro (destructivo)
  danger,
}

/// Tamaños de botón
enum KineonButtonSize { small, medium, large }

/// Botón premium Neo-cinema
class KineonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final KineonButtonVariant variant;
  final KineonButtonSize size;
  final bool loading;
  final bool enabled;
  final bool expanded;

  const KineonButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = KineonButtonVariant.primary,
    this.size = KineonButtonSize.medium,
    this.loading = false,
    this.enabled = true,
    this.expanded = false,
  });

  /// Botón solo icono
  factory KineonButton.icon({
    required IconData icon,
    VoidCallback? onPressed,
    KineonButtonVariant variant = KineonButtonVariant.secondary,
    KineonButtonSize size = KineonButtonSize.medium,
    bool enabled = true,
  }) {
    return KineonButton(
      label: '',
      icon: icon,
      onPressed: onPressed,
      variant: variant,
      size: size,
      enabled: enabled,
    );
  }

  @override
  State<KineonButton> createState() => _KineonButtonState();
}

class _KineonButtonState extends State<KineonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.instant,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.enabled && !widget.loading;
  bool get _isIconOnly => widget.label.isEmpty;

  double get _height {
    switch (widget.size) {
      case KineonButtonSize.small:
        return 36;
      case KineonButtonSize.medium:
        return 48;
      case KineonButtonSize.large:
        return 56;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case KineonButtonSize.small:
        return 16;
      case KineonButtonSize.medium:
        return 20;
      case KineonButtonSize.large:
        return 24;
    }
  }

  EdgeInsets get _padding {
    if (_isIconOnly) {
      return EdgeInsets.zero;
    }
    switch (widget.size) {
      case KineonButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14);
      case KineonButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20);
      case KineonButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case KineonButtonSize.small:
        return AppTypography.labelMedium;
      case KineonButtonSize.medium:
        return AppTypography.labelLarge;
      case KineonButtonSize.large:
        return AppTypography.labelLarge.copyWith(fontSize: 17);
    }
  }

  BoxDecoration _decoration(KineonColors colors) {
    final opacity = _isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case KineonButtonVariant.primary:
        return BoxDecoration(
          gradient: _isEnabled
              ? (_isPressed
                  ? LinearGradient(
                      colors: [
                        colors.accent.withOpacity(0.8),
                        colors.accentPurple.withOpacity(0.8),
                      ],
                    )
                  : AppColors.gradientPrimary)
              : null,
          color: _isEnabled ? null : colors.surfaceElevated,
          borderRadius: AppRadii.radiusMd,
          boxShadow: _isEnabled && !_isPressed
              ? AppShadows.glowAccent
              : null,
        );

      case KineonButtonVariant.secondary:
        return BoxDecoration(
          color: _isPressed
              ? colors.textPrimary.withOpacity(0.08 * opacity)
              : Colors.transparent,
          borderRadius: AppRadii.radiusMd,
          border: Border.all(
            color: colors.surfaceBorder.withOpacity(opacity),
            width: 1.5,
          ),
        );

      case KineonButtonVariant.tertiary:
        return BoxDecoration(
          color: _isPressed
              ? colors.textPrimary.withOpacity(0.06 * opacity)
              : Colors.transparent,
          borderRadius: AppRadii.radiusMd,
        );

      case KineonButtonVariant.danger:
        return BoxDecoration(
          color: _isPressed
              ? colors.error.withOpacity(0.15 * opacity)
              : colors.error.withOpacity(0.1 * opacity),
          borderRadius: AppRadii.radiusMd,
          border: Border.all(
            color: colors.error.withOpacity(0.3 * opacity),
            width: 1,
          ),
        );
    }
  }

  Color _contentColor(KineonColors colors) {
    if (!_isEnabled) {
      return colors.textTertiary;
    }

    switch (widget.variant) {
      case KineonButtonVariant.primary:
        return colors.textOnAccent;
      case KineonButtonVariant.secondary:
        return colors.textPrimary;
      case KineonButtonVariant.tertiary:
        return colors.textSecondary;
      case KineonButtonVariant.danger:
        return colors.error;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          height: _height,
          width: _isIconOnly ? _height : (widget.expanded ? double.infinity : null),
          padding: _padding,
          decoration: _decoration(colors),
          alignment: Alignment.center,
          child: widget.loading
              ? _buildLoading(colors)
              : _buildContent(colors),
        ),
      ),
    );
  }

  Widget _buildLoading(KineonColors colors) {
    return SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: _contentColor(colors),
      ),
    );
  }

  Widget _buildContent(KineonColors colors) {
    final contentColor = _contentColor(colors);

    if (_isIconOnly) {
      return Icon(
        widget.icon,
        size: _iconSize,
        color: contentColor,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _iconSize,
            color: contentColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: _textStyle.copyWith(color: contentColor),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(
            widget.trailingIcon,
            size: _iconSize,
            color: contentColor,
          ),
        ],
      ],
    );
  }
}

/// Botón de texto simple
class KineonTextButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool enabled;

  const KineonTextButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = enabled
        ? (color ?? colors.accent)
        : colors.textTertiary;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon button circular
class KineonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final bool enabled;

  const KineonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.enabled = true,
  });

  @override
  State<KineonIconButton> createState() => _KineonIconButtonState();
}

class _KineonIconButtonState extends State<KineonIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = widget.backgroundColor ?? colors.surfaceElevated;
    final iconColor = widget.enabled
        ? (widget.color ?? colors.textPrimary)
        : colors.textTertiary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed
              ? bgColor.withOpacity(0.8)
              : bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isPressed
                ? colors.textPrimary.withOpacity(0.1)
                : colors.surfaceBorder,
          ),
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.5,
          color: iconColor,
        ),
      ),
    );
  }
}
