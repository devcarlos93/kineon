import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons, Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_profile_data.dart';
import '../providers/profile_preferences_provider.dart';
import '../widgets/credits_footer.dart';
import '../widgets/kineon_pro_card.dart';
import '../widgets/notifications_section.dart';
import '../widgets/preferences_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/user_info_card.dart';

/// Pantalla de Perfil/Ajustes
class ProfileMockScreen extends ConsumerStatefulWidget {
  const ProfileMockScreen({super.key});

  @override
  ConsumerState<ProfileMockScreen> createState() => _ProfileMockScreenState();
}

class _ProfileMockScreenState extends ConsumerState<ProfileMockScreen> {
  // User state - obtener datos reales de Supabase
  UserProfile get _user {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final prefs = ref.read(profilePreferencesProvider).preferences;

    if (supabaseUser == null) return mockUserProfile;

    return UserProfile(
      id: supabaseUser.id,
      name: prefs.displayName ??
          supabaseUser.userMetadata?['full_name'] as String? ??
          supabaseUser.email?.split('@').first ??
          'Usuario',
      email: supabaseUser.email ?? '',
      avatarUrl: prefs.avatarUrl ?? supabaseUser.userMetadata?['avatar_url'] as String?,
      memberSince: prefs.memberSince ?? DateTime.tryParse(supabaseUser.createdAt),
      isPro: ref.read(isProProvider), // Verificar suscripción real con RevenueCat
    );
  }

  String _getAppearanceLabel(String themeMode) {
    final l10n = AppLocalizations.of(context);
    switch (themeMode) {
      case 'light':
        return l10n.strings.profileLightMode;
      case 'system':
        return l10n.strings.profileSystemMode;
      default:
        return l10n.strings.profileDarkMode;
    }
  }

  String _getLanguageLabel(String langCode) {
    switch (langCode) {
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  void _handleAvatarTap() {
    HapticFeedback.selectionClick();
    // TODO: Show avatar picker
  }

  void _handleUpgrade() async {
    HapticFeedback.mediumImpact();

    // Primero intentar restaurar compras existentes
    final restoreResult = await RevenueCatService().restorePurchases();
    debugPrint('Restore result: isPro=${restoreResult.isPro}');

    if (restoreResult.isPro) {
      // Ya tiene suscripción, refrescar UI
      if (mounted) setState(() {});
      return;
    }

    // Mostrar paywall de RevenueCat
    final result = await RevenueCatService().presentPaywall();
    debugPrint('Paywall result: $result');

    // Refrescar estado después del paywall
    await RevenueCatService().refreshStatus();
    if (mounted) setState(() {});
  }

  void _handleManageSubscription() async {
    HapticFeedback.lightImpact();
    // Mostrar Customer Center de RevenueCat
    await RevenueCatService().presentCustomerCenter();
  }

  void _handleSpoilersChanged(bool value) {
    ref.read(profilePreferencesProvider.notifier).setHideSpoilers(value);
  }

  void _handleRegionTap() {
    final prefs = ref.read(profilePreferencesProvider).preferences;
    _showRegionSelector(prefs.countryCode);
  }

  void _showRegionSelector(String currentCode) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _RegionSelectorModal(
        selectedCode: currentCode,
        onRegionSelected: (code) {
          ref.read(profilePreferencesProvider.notifier).setCountryCode(code);
        },
      ),
    );
  }

  void _handleAppearanceTap() {
    final prefs = ref.read(profilePreferencesProvider).preferences;
    _showAppearanceSelector(prefs.themeMode);
  }

  void _showAppearanceSelector(String currentMode) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _AppearanceSelectorModal(
        selectedMode: currentMode,
        onModeSelected: (mode) {
          ref.read(profilePreferencesProvider.notifier).setThemeMode(mode);
        },
      ),
    );
  }

  void _handleLanguageTap() {
    final prefs = ref.read(profilePreferencesProvider).preferences;
    _showLanguageSelector(prefs.preferredLanguage);
  }

  void _showLanguageSelector(String currentLang) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _LanguageSelectorModal(
        selectedLanguage: currentLang,
        onLanguageSelected: (language) {
          // Guardar en perfil (Supabase)
          ref.read(profilePreferencesProvider.notifier).setPreferredLanguage(language);
          // Actualizar locale de la app
          ref.read(localeProvider.notifier).setLocale(Locale(language));
        },
      ),
    );
  }

  void _handlePrivacyPolicy() {
    HapticFeedback.lightImpact();
    // TODO: Open privacy policy
  }

  void _handleTermsOfService() {
    HapticFeedback.lightImpact();
    // TODO: Open terms of service
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    _showLogoutConfirmation();
  }

  void _showLogoutConfirmation() {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.strings.profileLogout),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.strings.quickPrefsCancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.strings.profileLogout),
            onPressed: () async {
              Navigator.pop(ctx);
              await _performLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Track logout event before signing out
      AnalyticsService.instance.trackEvent(AnalyticsEvents.logout);
      AnalyticsService.instance.setUser(null);

      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      // Mostrar error si falla
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo cerrar sesión: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleDeleteAccount() {
    HapticFeedback.mediumImpact();
    _showDeleteAccountConfirmation();
  }

  void _showDeleteAccountConfirmation() {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.strings.profileDeleteAccount),
        content: Text(l10n.strings.profileDeleteAccountWarning),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.strings.quickPrefsCancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.strings.profileDeleteAccount),
            onPressed: () {
              Navigator.pop(ctx);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _performDeleteAccount();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    bool loadingDialogShown = false;

    // Mostrar loading
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const CupertinoAlertDialog(
        content: Padding(
          padding: EdgeInsets.all(20),
          child: CupertinoActivityIndicator(),
        ),
      ),
    ).then((_) => loadingDialogShown = false);
    loadingDialogShown = true;

    try {
      // Llamar a la función RPC para eliminar datos
      final result = await Supabase.instance.client
          .rpc('delete_my_account')
          .timeout(const Duration(seconds: 30));

      // Cerrar loading
      if (loadingDialogShown && mounted) {
        navigator.pop();
        loadingDialogShown = false;
      }

      final success = result?['success'] == true;

      if (success) {
        // Limpiar analytics
        AnalyticsService.instance.trackEvent('account_deleted');
        AnalyticsService.instance.setUser(null);

        // Cerrar sesión
        await Supabase.instance.client.auth.signOut();

        // Navegar a login
        if (mounted) {
          context.go(AppRoutes.login);
        }
      } else {
        throw Exception(result?['error'] ?? 'Unknown error');
      }
    } catch (e) {
      // Cerrar loading si sigue abierto
      if (loadingDialogShown && mounted) {
        navigator.pop();
        loadingDialogShown = false;
        // Pequeña pausa antes de mostrar el error
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Mostrar error
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(l10n.strings.profileDeleteAccountError),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: Material(
        color: Colors.transparent,
        child: Column(
        children: [
          // Header
          const ProfileHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // User info
                  UserInfoCard(
                    user: _user,
                    onAvatarTap: _handleAvatarTap,
                  ),

                  const SizedBox(height: 32),

                  // Kineon Pro Card or Status
                  if (_user.isPro)
                    KineonProStatusCard(
                      expiresAt: _user.proExpiresAt,
                      onManageTap: _handleManageSubscription,
                    )
                  else
                    KineonProCard(
                      plan: kineonProPlan,
                      isUserPro: _user.isPro,
                      onUpgrade: _handleUpgrade,
                      onManageSubscription: _handleManageSubscription,
                    ),

                  const SizedBox(height: 32),

                  // Preferences
                  Consumer(
                    builder: (context, ref, _) {
                      final prefsState = ref.watch(profilePreferencesProvider);
                      final prefs = prefsState.preferences;
                      final region = getRegionByCode(prefs.countryCode);

                      return PreferencesSection(
                        hideSpoilers: prefs.hideSpoilers,
                        selectedRegion: region.name,
                        selectedAppearance: _getAppearanceLabel(prefs.themeMode),
                        selectedLanguage: _getLanguageLabel(prefs.preferredLanguage),
                        onSpoilersChanged: _handleSpoilersChanged,
                        onRegionTap: _handleRegionTap,
                        onAppearanceTap: _handleAppearanceTap,
                        onLanguageTap: _handleLanguageTap,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Notifications
                  const NotificationsSection(),

                  const SizedBox(height: 32),

                  // Logout button
                  LogoutButton(onTap: _handleLogout),

                  const SizedBox(height: 32),

                  // Credits
                  CreditsFooter(
                    appVersion: appVersion,
                    onPrivacyPolicyTap: _handlePrivacyPolicy,
                    onTermsOfServiceTap: _handleTermsOfService,
                  ),

                  const SizedBox(height: 16),

                  // Delete account
                  DeleteAccountButton(onTap: _handleDeleteAccount),

                  // Espacio para bottom nav
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 120,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Modal de selección de idioma
class _LanguageSelectorModal extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;

  const _LanguageSelectorModal({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  static const _languages = [
    ('es', 'Español'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHandle(),
            _ModalHeader(title: l10n.strings.profileLanguage),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: _languages.map((lang) {
                  final (code, name) = lang;
                  final isSelected = code == selectedLanguage;
                  return _LanguageOption(
                    code: code,
                    label: name,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onLanguageSelected(code);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal de selección de región
class _RegionSelectorModal extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onRegionSelected;

  const _RegionSelectorModal({
    required this.selectedCode,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHandle(),
            _ModalHeader(title: l10n.strings.profileStreamingRegion),
            SizedBox(
              height: 350,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: availableStreamingRegions.map((region) {
                  final isSelected = region.code == selectedCode;
                  return _RegionOption(
                    code: region.code,
                    name: region.name,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onRegionSelected(region.code);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción de región con código de país estilizado
class _RegionOption extends StatelessWidget {
  final String code;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionOption({
    required this.code,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent.withValues(alpha: 0.4)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            // Código de país estilizado
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accent.withValues(alpha: 0.2)
                    : colors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? colors.accent.withValues(alpha: 0.4)
                      : colors.surfaceBorder,
                ),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? colors.accent : colors.textSecondary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? colors.accent : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark, color: colors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Modal de selección de apariencia
class _AppearanceSelectorModal extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeSelected;

  const _AppearanceSelectorModal({
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    final modes = [
      ('dark', l10n.strings.profileDarkMode, Icons.dark_mode_outlined),
      ('light', l10n.strings.profileLightMode, Icons.light_mode_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHandle(),
            _ModalHeader(title: l10n.strings.profileAppearance),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: modes.map((mode) {
                  final (code, name, icon) = mode;
                  final isSelected = code == selectedMode;
                  return _AppearanceOption(
                    icon: icon,
                    label: name,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onModeSelected(code);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción de apariencia con icono Material
class _AppearanceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent.withValues(alpha: 0.4)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.accent : colors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? colors.accent : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark, color: colors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODAL COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _ModalHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.textTertiary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  const _ModalHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

/// Opción de idioma con bandera SVG
class _LanguageOption extends StatelessWidget {
  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent.withValues(alpha: 0.4)
                : colors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            // Bandera SVG con bordes redondeados
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SvgPicture.asset(
                'assets/flags/$code.svg',
                width: 32,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? colors.accent : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark, color: colors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}
