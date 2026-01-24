import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kineon_logo.dart';

/// Pantalla de Splash que verifica el estado de autenticación
/// y redirige según corresponda.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const String _onboardingSeenKey = 'onboarding_seen';

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Esperar un poco para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Verificar si el usuario ya vio el onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_onboardingSeenKey) ?? false;

    // Verificar sesión de Supabase
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;

    if (!mounted) return;

    if (isAuthenticated) {
      // Usuario autenticado -> ir a home
      context.go(AppRoutes.home);
    } else if (hasSeenOnboarding) {
      // Ya vio onboarding pero no está autenticado -> ir a login
      context.go(AppRoutes.login);
    } else {
      // Primera vez -> ir a onboarding
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1A1A),
              Color(0xFF0B1015),
              Color(0xFF080C10),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              _buildLogo(colors)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 20),

              // Nombre de la app
              Text(
                'Kineon',
                style: AppTypography.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Cine, curado por IA.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 60),

              // Indicador de carga
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.accent.withValues(alpha: 0.7),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(KineonColors colors) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const KineonLogo(size: 100),
    );
  }
}
