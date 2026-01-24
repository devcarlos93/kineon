import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/kineon_colors.dart';

/// Card flotante estilo Neo-cinema
///
/// Características:
/// - Elevación sutil con sombras
/// - Bordes redondeados consistentes
/// - Animación de hover/press suave
class KineonCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadows;
  final bool elevated;
  final bool interactive;

  const KineonCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.shadows,
    this.elevated = false,
    this.interactive = true,
  });

  @override
  State<KineonCard> createState() => _KineonCardState();
}

class _KineonCardState extends State<KineonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.interactive || widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.interactive) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.interactive) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = widget.backgroundColor ??
        (widget.elevated ? colors.surfaceElevated : colors.surface);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.interactive ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isPressed
                ? bgColor.withOpacity(0.8)
                : bgColor,
            borderRadius: widget.borderRadius ?? AppRadii.radiusLg,
            border: widget.border ?? Border.all(
              color: _isPressed
                  ? colors.textPrimary.withOpacity(0.1)
                  : colors.surfaceBorder,
              width: 1,
            ),
            boxShadow: widget.shadows ??
                (widget.elevated ? AppShadows.md : AppShadows.sm),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Card compacta sin sombras para listas
class KineonCardFlat extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const KineonCardFlat({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: backgroundColor ?? colors.surface,
      borderRadius: borderRadius ?? AppRadii.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppRadii.radiusMd,
        splashColor: colors.accent.withOpacity(0.1),
        highlightColor: colors.textPrimary.withOpacity(0.05),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Card con gradiente para destacados
class KineonCardGradient extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  const KineonCardGradient({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.gradientPrimary,
          borderRadius: borderRadius ?? AppRadii.radiusLg,
          boxShadow: AppShadows.glowAccent,
        ),
        child: child,
      ),
    );
  }
}
