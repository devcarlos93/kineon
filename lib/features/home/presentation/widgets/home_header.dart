import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Header del Home con saludo, avatar y notificaciones
class HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final bool hasNotifications;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.hasNotifications = false,
    this.onAvatarTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceElevated,
                border: Border.all(
                  color: colors.surfaceBorder,
                  width: 2,
                ),
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      color: colors.textSecondary,
                      size: 24,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Saludo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeWelcome,
                  style: AppTypography.overline.copyWith(
                    color: colors.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.homeGreeting(userName),
                  style: AppTypography.h3.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Botón notificaciones (solo si hay callback)
          if (onNotificationsTap != null)
            GestureDetector(
              onTap: onNotificationsTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surfaceBorder,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: colors.textPrimary,
                      size: 22,
                    ),
                    // Indicador de notificaciones
                    if (hasNotifications)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
