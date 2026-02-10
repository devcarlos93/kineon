import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/pro_locked_overlay.dart';
import '../providers/smart_collections_provider.dart';
import 'smart_collection_card.dart';

/// Section displaying Smart Collections on the home screen
class SmartCollectionsSection extends ConsumerWidget {
  const SmartCollectionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(smartCollectionsProvider);
    final subscription = ref.watch(subscriptionProvider);
    final isPro = subscription.isPro;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Don't show section if empty and not loading
    if (!state.isLoading && state.collections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const KinoIcon(size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.smartCollections,
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (!isPro)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textOnAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.smartCollectionsSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Content
        if (state.isLoading)
          const _SkeletonCollections()
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.collections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final collection = state.collections[index];
                final card = SmartCollectionCard(
                  collection: collection,
                  locale: locale,
                  onTap: isPro
                      ? () => context.push('/collection/${collection.slug}')
                      : null,
                );
                // Free users: blur en todas las cards
                return ProLockedOverlay(
                  isLocked: !isPro,
                  blurSigma: 4.0,
                  child: card,
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Skeleton loading state for collections
class _SkeletonCollections extends StatelessWidget {
  const _SkeletonCollections();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: colors.surfaceElevated,
          highlightColor: AppColors.surfaceLight,
          child: Container(
            width: 280,
            height: 180,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
