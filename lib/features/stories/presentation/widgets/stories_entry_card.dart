import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../subscription/domain/entities/subscription_state.dart';
import '../../../subscription/presentation/helpers/gating_helper.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';

/// Card de entrada a Stories en el Home Screen
class StoriesEntryCard extends ConsumerWidget {
  const StoriesEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final subscription = ref.watch(subscriptionProvider);
    final isPro = subscription.isPro;
    final remaining = GatingHelper.getRemaining(ref, AIEndpoints.stories);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/stories'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF5EEAD4).withValues(alpha: 0.12),
                    const Color(0xFFA78BFA).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF5EEAD4).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // Kino avatar
                  const KinoAvatar(size: 44),

                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.storiesTitle,
                          style: AppTypography.labelLarge.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.storiesDescription,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // CTA / remaining counter
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5EEAD4).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF5EEAD4).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isPro ? l10n.storiesCta : l10n.storiesProFreeLabel,
                          style: TextStyle(
                            color: const Color(0xFF5EEAD4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPro && remaining < 999) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$remaining/5',
                          style: AppTypography.overline.copyWith(
                            color: colors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
