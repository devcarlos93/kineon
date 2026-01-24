import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/custom_list_providers.dart';

/// Modal que se muestra cuando el usuario alcanza el límite de listas (free)
class ListLimitModal extends StatelessWidget {
  final ListLimitReason reason;
  final int current;
  final int limit;

  const ListLimitModal({
    super.key,
    required this.reason,
    required this.current,
    required this.limit,
  });

  static Future<void> show(
    BuildContext context, {
    required ListLimitReason reason,
    required int current,
    required int limit,
  }) {
    HapticFeedback.mediumImpact();
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ListLimitModal(
        reason: reason,
        current: current,
        limit: limit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final isListLimit = reason == ListLimitReason.maxListsReached;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.lock_fill,
                    color: colors.accent,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                // Título
                Text(
                  isListLimit
                      ? l10n.strings.listLimitMaxListsTitle
                      : l10n.strings.listLimitMaxItemsTitle,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Descripción
                Text(
                  isListLimit
                      ? l10n.strings.listLimitMaxListsDesc(limit)
                      : l10n.strings.listLimitMaxItemsDesc(limit),
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Pro benefits
                Text(
                  l10n.strings.listLimitProBenefit,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Botón de upgrade
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile/subscription');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        l10n.strings.listLimitUpgrade,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textOnAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón de cerrar
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.strings.commonCancel,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
