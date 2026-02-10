import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/smart_collection.dart';
import '../providers/smart_collections_provider.dart';

/// Full detail screen for a smart collection
class SmartCollectionDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const SmartCollectionDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<SmartCollectionDetailScreen> createState() =>
      _SmartCollectionDetailScreenState();
}

class _SmartCollectionDetailScreenState
    extends ConsumerState<SmartCollectionDetailScreen> {
  SmartCollection? _collection;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    final notifier = ref.read(smartCollectionsProvider.notifier);

    // Try from cached state first
    var collection = notifier.findBySlug(widget.slug);

    // Fetch from server if not cached
    collection ??= await notifier.loadBySlug(widget.slug);

    if (mounted) {
      setState(() {
        _collection = collection;
        _isLoading = false;
      });
    }
  }

  void _shareCollection() {
    if (_collection == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    final title = _collection!.localizedTitle(locale);
    final l10n = AppLocalizations.of(context);
    Share.share(
      '${l10n.collectionShare}: "$title" - kineon://collection/${_collection!.slug}',
    );
  }

  void _onItemTap(SmartCollectionItem item) {
    context.push('/details/${item.contentType}/${item.tmdbId}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );
    }

    if (_collection == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.collections_outlined,
                  size: 64, color: colors.textTertiary),
              const SizedBox(height: 16),
              Text(
                l10n.collectionEmpty,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final collection = _collection!;
    final title = collection.localizedTitle(locale);
    final description = collection.localizedDescription(locale);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // Header with backdrop
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: colors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.share_outlined, color: Colors.white),
                ),
                onPressed: _shareCollection,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (collection.backdropUrlLarge != null)
                    CachedNetworkImage(
                      imageUrl: collection.backdropUrlLarge!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.accent.withValues(alpha: 0.4),
                            colors.accentPurple.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colors.background,
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          collection.iconData,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: AppTypography.h1.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.collectionItems(collection.items.length),
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = collection.items[index];
                  return _CollectionItemTile(
                    item: item,
                    locale: locale,
                    onTap: () => _onItemTap(item),
                  );
                },
                childCount: collection.items.length,
              ),
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single item tile in the collection detail
class _CollectionItemTile extends StatelessWidget {
  final SmartCollectionItem item;
  final String locale;
  final VoidCallback? onTap;

  const _CollectionItemTile({
    required this.item,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reason = item.localizedReason(locale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.posterUrl!,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 60,
                        height: 90,
                        color: colors.surfaceElevated,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 60,
                        height: 90,
                        color: colors.surfaceElevated,
                        child: Icon(Icons.movie_outlined,
                            color: colors.textTertiary, size: 24),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 90,
                      color: colors.surfaceElevated,
                      child: Icon(Icons.movie_outlined,
                          color: colors.textTertiary, size: 24),
                    ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title ?? 'TMDB #${item.tmdbId}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Type + Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.contentType == 'tv' ? 'TV' : 'Movie',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (item.voteAverage != null && item.voteAverage! > 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded,
                            size: 14, color: colors.warning),
                        const SizedBox(width: 2),
                        Text(
                          item.voteAverage!.toStringAsFixed(1),
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Reason
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.accent,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
