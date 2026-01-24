import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Footer de créditos con TMDB, legal y versión
class CreditsFooter extends StatelessWidget {
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onTermsOfServiceTap;
  final String appVersion;

  const CreditsFooter({
    super.key,
    this.onPrivacyPolicyTap,
    this.onTermsOfServiceTap,
    this.appVersion = '2.4.0',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // TMDB Attribution
          _TmdbAttribution(),

          const SizedBox(height: 24),

          // Legal links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegalLink(
                text: l10n.strings.profilePrivacyPolicy,
                onTap: onPrivacyPolicyTap,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              _LegalLink(
                text: l10n.strings.profileTermsOfService,
                onTap: onTermsOfServiceTap,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // App version
          Text(
            'Kineon AI v$appVersion',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),

          const SizedBox(height: 8),

          // Made with love
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.strings.profileMadeWith,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.heart_fill,
                color: colors.accent,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.strings.profileForCinephiles,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Atribución de TMDB
class _TmdbAttribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        children: [
          // TMDB Logo placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D253F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'TMDB',
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF01D277),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Attribution text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.strings.profileDataProvidedBy,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The Movie Database',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // External link icon
          Icon(
            CupertinoIcons.arrow_up_right_square,
            color: colors.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

/// Link legal
class _LegalLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _LegalLink({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: colors.accent,
        ),
      ),
    );
  }
}

/// Botón de logout
class LogoutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LogoutButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.mediumImpact();
            onTap!();
          }
        },
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              l10n.strings.profileLogout,
              style: AppTypography.labelLarge.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de eliminar cuenta
class DeleteAccountButton extends StatelessWidget {
  final VoidCallback? onTap;

  const DeleteAccountButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.mediumImpact();
            onTap!();
          }
        },
        child: Text(
          l10n.strings.profileDeleteAccount,
          style: AppTypography.bodySmall.copyWith(
            color: colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
