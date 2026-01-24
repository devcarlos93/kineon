import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/kineon_colors.dart';

/// Contenedor con efecto glass (glassmorphism sutil)
///
/// Estilo Neo-cinema: blur suave, borde luminoso sutil
class KineonGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;

  const KineonGlass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 8,
    this.color,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadii.radiusLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? colors.surface).withOpacity(0.7),
                  (color ?? colors.surface).withOpacity(0.5),
                ],
              ),
              borderRadius: borderRadius ?? AppRadii.radiusLg,
              border: border ?? Border.all(
                color: colors.textPrimary.withOpacity(0.06),
                width: 1,
              ),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Contenedor glass más sutil para overlays
class KineonGlassOverlay extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const KineonGlassOverlay({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: borderRadius ?? AppRadii.radiusSm,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colors.background.withOpacity(0.6),
            borderRadius: borderRadius ?? AppRadii.radiusSm,
            border: Border.all(
              color: colors.textPrimary.withOpacity(0.04),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Pill glass para badges/tags sobre imágenes
class KineonGlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const KineonGlassPill({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: AppRadii.radiusFull,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: (backgroundColor ?? colors.background).withOpacity(0.7),
            borderRadius: AppRadii.radiusFull,
          ),
          child: child,
        ),
      ),
    );
  }
}
