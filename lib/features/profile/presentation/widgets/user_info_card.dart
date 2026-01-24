import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_profile_data.dart';

/// Card de información del usuario
class UserInfoCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onAvatarTap;

  const UserInfoCard({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final memberYear = user.memberSince?.year ?? 2023;

    return Column(
      children: [
        // Avatar
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8A87C),
                  Color(0xFFD4956A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colors.surfaceBorder,
                width: 3,
              ),
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      _getInitials(user.name),
                      style: AppTypography.h2.copyWith(
                        color: colors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          user.name,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          user.email,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.accent,
          ),
        ),

        const SizedBox(height: 4),

        // Member since
        Text(
          '${l10n.strings.profileMemberSince} $memberYear',
          style: AppTypography.bodySmall.copyWith(
            color: colors.textTertiary,
          ),
        ),

        // Pro badge
        if (user.isPro) ...[
          const SizedBox(height: 12),
          _ProBadge(),
        ],
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

/// Badge de usuario Pro
class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.star_fill,
            color: colors.textOnAccent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'PRO',
            style: AppTypography.labelSmall.copyWith(
              color: colors.textOnAccent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton de UserInfoCard
class UserInfoCardSkeleton extends StatelessWidget {
  const UserInfoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        // Avatar skeleton
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 16),
        // Name skeleton
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Email skeleton
        Container(
          width: 180,
          height: 14,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Member since skeleton
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
