import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Overlay de blur + candado Pro que se pone encima de contenido premium.
/// Free users ven el contenido borroso con un badge "PRO" para desbloquear.
class ProLockedOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final double blurSigma;

  const ProLockedOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    this.blurSigma = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/profile/subscription');
      },
      child: Stack(
        children: [
          // Contenido original (se ve borroso)
          child,

          // Blur overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: Container(
                  color: colors.background.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          // Lock badge central
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: colors.textOnAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PRO',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.textOnAccent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
