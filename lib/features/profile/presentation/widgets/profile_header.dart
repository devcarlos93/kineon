import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Header de la pantalla de perfil
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;

  const ProfileHeader({
    super.key,
    this.onBackTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        4,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Row(
        children: [
          // Back button
          if (onBackTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onBackTap!();
              },
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.surfaceBorder),
                ),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: colors.textPrimary,
                  size: 20,
                ),
              ),
            ),

          // Title (centered)
          Expanded(
            child: Text(
              l10n.strings.profileTitle,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Settings button
          if (onSettingsTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSettingsTap!();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.surfaceBorder),
                ),
                child: Icon(
                  CupertinoIcons.gear,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
