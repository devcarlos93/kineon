import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kineon_logo.dart';
import '../providers/onboarding_preferences_provider.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/preferences_selector.dart';

/// Pantalla de Onboarding Neo-cinema de Kineon
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  int _currentPage = 0;
  bool _isNavigating = false;

  /// Genera los slides con traducciones
  List<OnboardingSlideData> _getSlides(AppLocalizations l10n) => [
    OnboardingSlideData(
      title: l10n.onboardingTitle1,
      titleAccent: l10n.onboardingAccent1,
      description: l10n.onboardingDesc1,
      illustration: OnboardingIllustration.cinema,
    ),
    OnboardingSlideData(
      title: l10n.onboardingTitle2,
      titleAccent: l10n.onboardingAccent2,
      description: l10n.onboardingDesc2,
      illustration: OnboardingIllustration.mood,
    ),
    OnboardingSlideData(
      title: l10n.onboardingTitle3,
      titleAccent: l10n.onboardingAccent3,
      description: l10n.onboardingDesc3,
      illustration: OnboardingIllustration.lists,
    ),
    OnboardingSlideData(
      title: l10n.onboardingTitle4,
      titleAccent: l10n.onboardingAccent4,
      description: l10n.onboardingDesc4,
      illustration: OnboardingIllustration.proTeaser,
    ),
  ];

  // Número total de páginas (constante: 4 slides + 1 preferencias)
  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage && page >= 0 && page < _totalPages) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  /// Maneja el tap del botón principal (Siguiente o Comenzar)
  void _onPrimaryButtonTap() {
    if (_isNavigating) return;

    final currentPage = _pageController.page?.round() ?? _currentPage;

    if (currentPage >= _totalPages - 1) {
      // Última página: ir a login
      _finish();
    } else {
      // No es la última: ir a siguiente página
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _skip() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await _markOnboardingSeen();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _finish() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await _savePreferencesLocally();
    await _markOnboardingSeen();
    if (mounted) context.go(AppRoutes.login);
  }

  /// Guarda las preferencias del onboarding en SharedPreferences
  /// para que no se pierdan al navegar al login
  Future<void> _savePreferencesLocally() async {
    final prefsState = ref.read(onboardingPreferencesProvider);

    // Debug: mostrar qué hay en el provider
    debugPrint('=== ONBOARDING PREFS DEBUG ===');
    debugPrint('selectedGenres: ${prefsState.selectedGenres}');
    debugPrint('selectedMoods: ${prefsState.selectedMoods}');
    debugPrint('moodText: ${prefsState.moodText}');
    debugPrint('hasSelections: ${prefsState.hasSelections}');

    final prefs = await SharedPreferences.getInstance();

    // Guardar géneros como lista de IDs (incluso si está vacío)
    final genreIds = prefsState.selectedGenres
        .map((g) => g.tmdbId)
        .toList();

    debugPrint('genreIds to save: $genreIds');

    await prefs.setStringList(
      'onboarding_genres',
      genreIds.map((id) => id.toString()).toList(),
    );

    // Guardar mood text
    final moodText = prefsState.combinedMoodText;
    await prefs.setString('onboarding_mood', moodText);

    debugPrint('Saved to SharedPreferences: genres=$genreIds, mood=$moodText');
  }

  /// Marca el onboarding como visto en SharedPreferences
  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _getSlides(l10n);

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // FONDO CON DEGRADADO PRINCIPAL
          // ═══════════════════════════════════════════════════════════
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F1A1A), // Verde-azulado oscuro arriba
                    Color(0xFF0B1015), // Azul muy oscuro medio
                    Color(0xFF080C10), // Casi negro abajo
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // FORMAS ABSTRACTAS ANIMADAS
          // ═══════════════════════════════════════════════════════════
          _AnimatedBackground(controller: _backgroundController),

          // Grain texture overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GrainPainter(),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // CONTENIDO PRINCIPAL
          // ═══════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(l10n),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (index) {
                      if (index >= 0 && index < _totalPages) {
                        setState(() => _currentPage = index);
                      }
                    },
                    itemCount: _totalPages,
                    itemBuilder: (context, index) {
                      if (index < slides.length) {
                        return OnboardingSlide(
                          data: slides[index],
                          isActive: _currentPage == index,
                        );
                      } else {
                        return PreferencesSelector(
                          isActive: _currentPage == index,
                        );
                      }
                    },
                  ),
                ),

                // Footer
                _buildFooter(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final colors = context.colors;
    final currentLocale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              const KineonLogo(size: 36),
              const SizedBox(width: 10),
              Text(
                'Kineon',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

          // Language selector + Skip button
          Row(
            children: [
              // Selector de idioma
              _LanguageSelector(
                currentLocale: currentLocale,
                onLocaleChanged: (locale) {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  ref.read(regionalPrefsProvider.notifier).setLanguage(locale.languageCode);
                },
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(width: 8),

              // Skip button
              TextButton(
                onPressed: _skip,
                child: Text(
                  l10n.onboardingSkip,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    final colors = context.colors;
    final isLastSlide = _currentPage == _totalPages - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Izquierda: PASO + Dots
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dots
              Row(
                children: List.generate(_totalPages, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: isActive ? 24 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.accent
                          : colors.textTertiary.withAlpha(77),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // Paso indicator
              Text(
                l10n.onboardingStep(_currentPage + 1, _totalPages),
                style: AppTypography.overline.copyWith(
                  color: colors.textTertiary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          // Derecha: Botón
          _PrimaryButton(
            label: isLastSlide ? l10n.onboardingStart : l10n.onboardingNext,
            onPressed: _onPrimaryButtonTap,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SELECTOR DE IDIOMA
// ═══════════════════════════════════════════════════════════════════════════

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10n.getLanguageFlag(currentLocale),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetColors = sheetContext.colors;
        final l10n = AppLocalizations.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.selectLanguage,
                  style: AppTypography.h2,
                ),

                const SizedBox(height: 20),

                // Language options
                ...L10n.supportedLocales.map((locale) {
                  final isSelected = locale == currentLocale;

                  return GestureDetector(
                    onTap: () {
                      onLocaleChanged(locale);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? sheetColors.accent.withAlpha(26)
                            : sheetColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? sheetColors.accent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            L10n.getLanguageFlag(locale),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              L10n.getLanguageName(locale),
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: sheetColors.accent,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTÓN PRIMARIO PREMIUM
// ═══════════════════════════════════════════════════════════════════════════

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed
              ? colors.accent.withOpacity(0.85)
              : colors.accent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isPressed ? null : [
            BoxShadow(
              color: colors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AppTypography.labelLarge.copyWith(
                color: colors.textOnAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: colors.textOnAccent,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FONDO ANIMADO CON FORMAS ABSTRACTAS
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Forma 1 - Círculo grande turquesa difuso
            Positioned(
              top: size.height * 0.1 + math.sin(controller.value * 2 * math.pi) * 20,
              right: -100 + math.cos(controller.value * 2 * math.pi) * 15,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accent.withOpacity(0.08),
                      colors.accent.withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Forma 2 - Elipse morada
            Positioned(
              bottom: size.height * 0.2 + math.cos(controller.value * 2 * math.pi) * 25,
              left: -80 + math.sin(controller.value * 2 * math.pi) * 10,
              child: Transform.rotate(
                angle: controller.value * 0.3,
                child: Container(
                  width: 250,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: RadialGradient(
                      colors: [
                        colors.accentPurple.withOpacity(0.06),
                        colors.accentPurple.withOpacity(0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Forma 3 - Círculo pequeño lime
            Positioned(
              top: size.height * 0.5 + math.sin(controller.value * 2 * math.pi + 1) * 15,
              right: size.width * 0.2 + math.cos(controller.value * 2 * math.pi + 1) * 10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.accentLime.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRAIN TEXTURE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _GrainPainter extends CustomPainter {
  final math.Random _random = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(4)
      ..strokeWidth = 1;

    // Dibujar puntos aleatorios para simular grain
    for (int i = 0; i < 2000; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

