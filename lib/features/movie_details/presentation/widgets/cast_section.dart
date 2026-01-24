import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_movie_detail.dart';

/// Sección del reparto con avatares horizontales
class CastSection extends StatelessWidget {
  final List<MockCastMember> cast;
  final VoidCallback? onSeeAllTap;

  const CastSection({
    super.key,
    required this.cast,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    if (cast.isEmpty) {
      return _EmptyCast(message: l10n.detailNoCast);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.detailCast,
                style: AppTypography.overline.copyWith(
                  color: colors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              if (cast.length > 6 && onSeeAllTap != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onSeeAllTap,
                  child: Text(
                    l10n.detailSeeAll,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal list
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cast.length > 10 ? 10 : cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < cast.length - 1 ? 16 : 0,
                ),
                child: _CastCard(member: member),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final MockCastMember member;

  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.surfaceBorder,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: member.profileUrl != null
                  ? CachedNetworkImage(
                      imageUrl: member.profileUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceElevated,
                        child: const Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => _AvatarPlaceholder(),
                    )
                  : _AvatarPlaceholder(),
            ),
          ),

          const SizedBox(height: 10),

          // Name
          Text(
            member.name,
            style: AppTypography.labelSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 2),

          // Character
          Text(
            member.character,
            style: AppTypography.labelSmall.copyWith(
              color: colors.textTertiary,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.surfaceElevated,
      child: Icon(
        CupertinoIcons.person_fill,
        color: colors.textTertiary,
        size: 32,
      ),
    );
  }
}

class _EmptyCast extends StatelessWidget {
  final String message;

  const _EmptyCast({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.person_2,
            color: colors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para la sección de cast
class CastSkeleton extends StatelessWidget {
  const CastSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 4 ? 16 : 0),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 45,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
