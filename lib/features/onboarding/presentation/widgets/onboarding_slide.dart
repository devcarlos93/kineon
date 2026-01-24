import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_preferences_provider.dart';

/// Tipos de ilustración para los slides
enum OnboardingIllustration { cinema, mood, lists }

/// Datos para un slide de onboarding
class OnboardingSlideData {
  final String title;
  final String titleAccent;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingSlideData({
    required this.title,
    required this.titleAccent,
    required this.description,
    required this.illustration,
  });
}

/// Slide individual del onboarding
class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData data;
  final bool isActive;

  const OnboardingSlide({
    super.key,
    required this.data,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════
          // ILUSTRACIÓN
          // ═══════════════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: _OnboardingIllustration(
              type: data.illustration,
              isActive: isActive,
            ),
          ),

          const SizedBox(height: 32),

          // ═══════════════════════════════════════════════════════════
          // TEXTO
          // ═══════════════════════════════════════════════════════════
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con acento
                if (isActive) ...[
                  Text(
                    data.title,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  Text(
                    data.titleAccent,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                      height: 1.15,
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // Descripción
                  Text(
                    data.description,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.15),
                ] else ...[
                  Text(
                    data.title,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    data.titleAccent,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.description,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ILUSTRACIÓN ABSTRACTA (Cinema, Mood, Lists)
// ═══════════════════════════════════════════════════════════════════════════

class _OnboardingIllustration extends StatelessWidget {
  final OnboardingIllustration type;
  final bool isActive;

  const _OnboardingIllustration({
    required this.type,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    switch (type) {
      case OnboardingIllustration.cinema:
        content = _CinemaIllustration();
      case OnboardingIllustration.mood:
        content = _MoodIllustration();
      case OnboardingIllustration.lists:
        content = _ListsIllustration();
    }

    if (isActive) {
      return content
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 600.ms, curve: Curves.easeOutCubic);
    }
    
    return content;
  }
}

/// Ilustración de cine/teatro con animación Lottie
class _CinemaIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceElevated,
            colors.surface,
            colors.background,
          ],
        ),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Fondo con gradiente sutil
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      colors.accent.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Animación Lottie de partículas cinematográficas
            Positioned.fill(
              child: Lottie.asset(
                'assets/animations/cinema_particles.json',
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
            ),

            // Pantalla de cine (marco)
            Positioned.fill(
              child: CustomPaint(
                painter: _CinemaScreenPainter(
                  surfaceElevated: colors.surfaceElevated,
                  surface: colors.surface,
                  textPrimary: colors.textPrimary,
                ),
              ),
            ),

            // Efecto de luz spotlight superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.accent.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Reflejo inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors.accent.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Viñeta sutil
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      colors.background.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustración de mood/tiempo - INTERACTIVA
class _MoodIllustration extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsState = ref.watch(onboardingPreferencesProvider);
    final selectedMoods = prefsState.selectedMoods;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chips de moods - INTERACTIVOS
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: availableMoods.take(4).map((mood) {
              final isSelected = selectedMoods.contains(mood);
              return _MoodChip(
                label: mood,
                isSelected: isSelected,
                onTap: () {
                  ref.read(onboardingPreferencesProvider.notifier).toggleMood(mood);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Chip de tiempo (decorativo)
          _MoodChip(
            label: '90 min',
            isSelected: true,
            isTime: true,
          ),
        ],
      ),
    );
  }
}

/// Ilustración de listas
class _ListsIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cards de listas apiladas
          Positioned(
            top: 40,
            child: Transform.rotate(
              angle: -0.08,
              child: _ListCard(
                title: 'Watchlist',
                count: 24,
                color: colors.accent,
              ),
            ),
          ),
          Positioned(
            top: 80,
            child: Transform.rotate(
              angle: 0.05,
              child: _ListCard(
                title: 'Favoritas',
                count: 12,
                color: colors.accentPurple,
              ),
            ),
          ),
          Positioned(
            top: 120,
            child: _ListCard(
              title: 'Vistas',
              count: 156,
              color: colors.accentLime,
              isMain: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPONENTES AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Chip de mood - ahora interactivo
class _MoodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isTime;
  final VoidCallback? onTap;

  const _MoodChip({
    required this.label,
    this.isSelected = false,
    this.isTime = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isTime ? 24 : 20,
          vertical: isTime ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : colors.surfaceBorder,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? colors.accent : colors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final bool isMain;

  const _ListCard({
    required this.title,
    required this.count,
    required this.color,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMain ? colors.surfaceElevated : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain ? color.withOpacity(0.3) : colors.surfaceBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isMain ? 0.3 : 0.15),
            blurRadius: isMain ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  '$count títulos',
                  style: AppTypography.caption.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (title) {
      case 'Watchlist':
        return Icons.bookmark_rounded;
      case 'Favoritas':
        return Icons.favorite_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
}

class _CinemaScreenPainter extends CustomPainter {
  final Color surfaceElevated;
  final Color surface;
  final Color textPrimary;

  _CinemaScreenPainter({
    required this.surfaceElevated,
    required this.surface,
    required this.textPrimary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          surfaceElevated,
          surface,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Pantalla
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.15,
        size.width * 0.8,
        size.height * 0.5,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(screenRect, paint);

    // Borde de la pantalla
    final borderPaint = Paint()
      ..color = textPrimary.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(screenRect, borderPaint);

    // Líneas de luz
    final lightPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.2 + (i * size.height * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.15, y),
        Offset(size.width * 0.85, y),
        lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CinemaScreenPainter oldDelegate) {
    return surfaceElevated != oldDelegate.surfaceElevated ||
        surface != oldDelegate.surface ||
        textPrimary != oldDelegate.textPrimary;
  }
}
