import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/watch_providers_provider.dart';

/// Sección "Dónde verla" con logos de streaming
class WatchProvidersSection extends ConsumerWidget {
  final int tmdbId;
  final bool isMovie;

  const WatchProvidersSection({
    super.key,
    required this.tmdbId,
    required this.isMovie,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(
      watchProvidersProvider(WatchProvidersParams(
        tmdbId: tmdbId,
        isMovie: isMovie,
      )),
    );

    return providersAsync.when(
      loading: () => const _LoadingState(),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) {
        if (!result.hasProviders) {
          return const SizedBox.shrink();
        }
        return _ProvidersContent(result: result);
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.textTertiary,
            ),
          ),
          Text(
            'Cargando...',
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvidersContent extends StatelessWidget {
  final WatchProvidersResult result;

  const _ProvidersContent({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 20,
              color: colors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.whereToWatch,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Streaming (flatrate + free)
        if (result.hasStreaming) ...[
          _ProviderCategory(
            label: l10n.watchProviderStreaming,
            providers: result.streaming,
            accentColor: colors.accent,
          ),
          const SizedBox(height: 12),
        ],

        // Alquiler
        if (result.rent.isNotEmpty) ...[
          _ProviderCategory(
            label: l10n.watchProviderRent,
            providers: result.rent,
            accentColor: colors.accentPurple,
          ),
          const SizedBox(height: 12),
        ],

        // Compra
        if (result.buy.isNotEmpty) ...[
          _ProviderCategory(
            label: l10n.watchProviderBuy,
            providers: result.buy,
            accentColor: colors.textSecondary,
          ),
        ],

        // Link a JustWatch
        if (result.link != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openLink(result.link!),
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: colors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.watchProviderPoweredBy,
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ProviderCategory extends StatelessWidget {
  final String label;
  final List<WatchProvider> providers;
  final Color accentColor;

  const _ProviderCategory({
    required this.label,
    required this.providers,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Logos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providers.take(8).map((provider) {
            return _ProviderLogo(
              provider: provider,
              accentColor: accentColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final WatchProvider provider;
  final Color accentColor;

  const _ProviderLogo({
    required this.provider,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: provider.providerName,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: CachedNetworkImage(
            imageUrl: provider.logoUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: colors.surface,
              child: Icon(
                Icons.play_arrow,
                color: colors.textTertiary,
                size: 16,
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: colors.surface,
              child: Center(
                child: Text(
                  provider.providerName.substring(0, 1),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
