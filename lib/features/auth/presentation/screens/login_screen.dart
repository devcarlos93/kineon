import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kineon_logo.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../data/services/apple_auth_service.dart';
import '../../data/services/google_auth_service.dart';

/// Pantalla de Login/Registro Neo-cinema de Kineon
class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectUrl;

  const LoginScreen({super.key, this.redirectUrl});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        if (data.event == AuthChangeEvent.signedIn && mounted) {
          // Track login event
          final user = data.session?.user;
          final provider = user?.appMetadata['provider'] as String? ?? 'unknown';
          ref.read(analyticsServiceProvider).trackEvent(
            AnalyticsEvents.login,
            properties: {'provider': provider},
          );
          // Set user in analytics
          if (user != null) {
            ref.read(analyticsServiceProvider).setUser(user.id, email: user.email);
            // Vincular usuario con RevenueCat
            await RevenueCatService().loginUser(user.id);
          }
          // Sincronizar preferencias del onboarding a Supabase
          await _syncOnboardingPreferences();
          if (mounted) {
            GoRouter.of(context).goAfterLogin(widget.redirectUrl);
          }
        }
      },
    );
  }

  /// Sincroniza las preferencias del onboarding a Supabase después del login
  Future<void> _syncOnboardingPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Leer preferencias guardadas en SharedPreferences
      final genreStrings = prefs.getStringList('onboarding_genres');
      final moodText = prefs.getString('onboarding_mood') ?? '';

      // Si no hay preferencias guardadas, salir
      if ((genreStrings == null || genreStrings.isEmpty) && moodText.isEmpty) {
        return;
      }

      // Convertir strings a IDs
      final genreIds = genreStrings
          ?.map((s) => int.tryParse(s))
          .whereType<int>()
          .toList() ?? [];

      // Guardar en Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return;
      }

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'preferred_genres': genreIds,
        'mood_text': moodText,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Limpiar preferencias temporales de SharedPreferences
      await prefs.remove('onboarding_genres');
      await prefs.remove('onboarding_mood');

      // Marcar que hay nuevas preferencias para que HomeScreen recargue
      await prefs.setBool('new_preferences_saved', true);
    } catch (e) {
      // Silently fail - preferences will sync on next login
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el servicio nativo de Google Sign-In
      final googleAuthService = ref.read(googleAuthServiceProvider);
      await googleAuthService.signIn();
      // El listener de auth detectará el cambio y redirigirá
    } on GoogleAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context).loginErrorGoogle);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el servicio nativo de Apple Sign-In
      final appleAuthService = ref.read(appleAuthServiceProvider);
      await appleAuthService.signIn();
      // El listener de auth detectará el cambio y redirigirá
    } on AppleAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context).loginErrorApple);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // FONDO CON DEGRADADO
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
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // CONTENIDO
          // ═══════════════════════════════════════════════════════════
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════
                  // HEADER - Logo alineado a la izquierda
                  // ═══════════════════════════════════════════════════════════
                  _buildHeader(l10n),

                  const Spacer(flex: 2),

                  // ═══════════════════════════════════════════════════════════
                  // HEADLINE Y TAGLINE
                  // ═══════════════════════════════════════════════════════════
                  _buildHeadline(l10n),

                  const Spacer(flex: 3),

              // ═══════════════════════════════════════════════════════════
              // BOTONES DE AUTENTICACIÓN
              // ═══════════════════════════════════════════════════════════
              _buildAuthButtons(l10n),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(),
              ],

              const Spacer(flex: 3),

              // ═══════════════════════════════════════════════════════════
              // SOCIAL PROOF + LEGAL
              // ═══════════════════════════════════════════════════════════
              _buildSocialProof(l10n),

              const SizedBox(height: 16),

              _buildLegalDisclaimer(l10n),

              const SizedBox(height: 32),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KineonLogo(size: 36),
        const SizedBox(width: 10),
        Text(
          l10n.appName,
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildHeadline(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loginHeadline1,
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        Text(
          l10n.loginHeadline2,
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        Text(
          l10n.loginHeadline3,
          style: AppTypography.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.loginTagline,
          style: AppTypography.bodyLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildAuthButtons(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      children: [
        // Continue with Apple (blanco)
        _AuthButton(
          label: l10n.loginContinueApple,
          icon: SvgPicture.asset(
            'assets/icons/apple.svg',
            width: 29,
            height: 29,
            colorFilter: const ColorFilter.mode(
              Color(0xFF1D1D1F),
              BlendMode.srcIn,
            ),
          ),
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1D1D1F),
          onPressed: _isLoading ? null : _loginWithApple,
          isLoading: _isLoading,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

        const SizedBox(height: 12),

        // Continue with Google (gris oscuro con borde)
        _AuthButton(
          label: l10n.loginContinueGoogle,
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 18,
            height: 18,
          ),
          backgroundColor: colors.surface,
          textColor: colors.textPrimary,
          hasBorder: true,
          onPressed: _isLoading ? null : _loginWithGoogle,
          isLoading: _isLoading,
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildErrorCard() {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: colors.error),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: Icon(Icons.close_rounded, color: colors.error, size: 16),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSocialProof(AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: Column(
        children: [
          // Iconos superpuestos
          SizedBox(
            width: 120,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icono 1 - Claqueta
                Positioned(
                  left: 0,
                  child: _SocialProofIcon(
                    emoji: '🎬',
                    backgroundColor: const Color(0xFF1A3A3A),
                  ),
                ),
                // Icono 2 - Palomitas (centro)
                Positioned(
                  left: 32,
                  child: _SocialProofIcon(
                    emoji: '🍿',
                    backgroundColor: const Color(0xFF2A3A3A),
                  ),
                ),
                // Icono 3 - Estrellas
                Positioned(
                  left: 64,
                  child: _SocialProofIcon(
                    emoji: '✨',
                    backgroundColor: colors.accent.withAlpha(77),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.loginSocialProof,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildLegalDisclaimer(AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTypography.caption.copyWith(
            color: colors.textTertiary,
            height: 1.5,
          ),
          children: [
            TextSpan(text: '${l10n.loginTermsPrefix}\n'),
            TextSpan(
              text: l10n.loginTermsOfService,
              style: AppTypography.caption.copyWith(
                color: colors.textTertiary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' & '),
            TextSpan(
              text: l10n.loginPrivacyPolicy,
              style: AppTypography.caption.copyWith(
                color: colors.textTertiary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTÓN DE AUTENTICACIÓN
// ═══════════════════════════════════════════════════════════════════════════

class _AuthButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final bool hasBorder;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.hasBorder = false,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withValues(alpha: 0.85)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: widget.hasBorder
              ? Border.all(color: colors.textTertiary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                ),
              )
            else
              widget.icon,
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: AppTypography.labelLarge.copyWith(
                color: widget.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOCIAL PROOF ICON
// ═══════════════════════════════════════════════════════════════════════════

class _SocialProofIcon extends StatelessWidget {
  final String emoji;
  final Color backgroundColor;

  const _SocialProofIcon({
    required this.emoji,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.background,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

