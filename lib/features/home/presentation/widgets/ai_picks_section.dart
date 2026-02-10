import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../../../library/data/repositories/library_repository.dart';
import '../../domain/entities/media_item.dart';
import '../providers/ai_picks_provider.dart';

/// Seccion "Para ti hoy" con recomendaciones IA
///
/// Muestra un card destacado con swipe y botones de acción.
class AIPicksSection extends StatefulWidget {
  final List<AIPick> picks;
  final bool isLoading;
  final bool isRefining;
  final bool isRefreshing; // Indica que se está actualizando en background
  final String source;
  final String personalizationType;
  final bool hasPreferences;
  final Map<int, MediaState> mediaStates;
  final Function(MediaItem)? onItemTap;
  final Function(MediaItem)? onAddToList;
  final Function(MediaItem)? onNotInterested;
  final VoidCallback? onRefresh;
  final VoidCallback? onRefinePreferences;

  const AIPicksSection({
    super.key,
    required this.picks,
    this.isLoading = false,
    this.isRefining = false,
    this.isRefreshing = false,
    this.source = 'none',
    this.personalizationType = 'trending',
    this.hasPreferences = false,
    this.mediaStates = const {},
    this.onItemTap,
    this.onAddToList,
    this.onNotInterested,
    this.onRefresh,
    this.onRefinePreferences,
  });

  @override
  State<AIPicksSection> createState() => _AIPicksSectionState();
}

class _AIPicksSectionState extends State<AIPicksSection> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  AIPick? get _currentPick =>
      widget.picks.isNotEmpty && _currentIndex < widget.picks.length
          ? widget.picks[_currentIndex]
          : null;

  MediaState? get _currentMediaState =>
      _currentPick != null ? widget.mediaStates[_currentPick!.item.id] : null;

  String _getSubtitle(AppLocalizations l10n) {
    switch (widget.personalizationType) {
      case 'preferences':
        return l10n.aiPicksBasedOnPreferences;
      case 'history':
        return l10n.aiPicksBasedOnHistory;
      case 'trending':
      default:
        return widget.hasPreferences ? l10n.aiPicksTrending : l10n.aiPicksColdStart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header compacto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeForYouToday,
                    style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(l10n),
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Action buttons
              Row(
                children: [
                  // Refine preferences button
                  if (widget.onRefinePreferences != null)
                    GestureDetector(
                      onTap: widget.onRefinePreferences,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.aiPicksRefine,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Refresh button (con indicador si está actualizando)
                  if (widget.onRefresh != null)
                    GestureDetector(
                      onTap: widget.isRefreshing ? null : widget.onRefresh,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.surfaceBorder),
                        ),
                        child: widget.isRefreshing
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.accent,
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Card principal con PageView
        if (widget.isLoading || widget.isRefining)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SkeletonAIPickCard(
              message: widget.isRefining ? AppLocalizations.of(context).kinoRefiningPicks : null,
            ),
          )
        else if (widget.picks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _EmptyState(onRefresh: widget.onRefresh),
          )
        else
          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.picks.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final pick = widget.picks[index];
                final state = widget.mediaStates[pick.item.id];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _AIPickCard(
                    pick: pick,
                    showAIBadge: widget.source == 'ai',
                    isInWatchlist: state?.isInWatchlist ?? false,
                    onTap: () => widget.onItemTap?.call(pick.item),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // Page indicator
        if (widget.picks.length > 1 && !widget.isLoading)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.picks.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.accent
                        : colors.textTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

        const SizedBox(height: 20),

        // Action buttons
        if (widget.picks.isNotEmpty && !widget.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Add to list
                Expanded(
                  child: _ActionButton(
                    icon: Icons.bookmark_outline_rounded,
                    activeIcon: Icons.bookmark_rounded,
                    label: l10n.homeMyList.toUpperCase(),
                    isActive: _currentMediaState?.isInWatchlist ?? false,
                    color: colors.accent,
                    onTap: () {
                      if (_currentPick != null) {
                        widget.onAddToList?.call(_currentPick!.item);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Not interested
                Expanded(
                  child: _ActionButton(
                    icon: Icons.close_rounded,
                    label: l10n.homeNotInterested.replaceAll('\n', ' ').toUpperCase(),
                    color: colors.textSecondary,
                    onTap: () {
                      if (_currentPick != null) {
                        widget.onNotInterested?.call(_currentPick!.item);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // View details
                Expanded(
                  child: _ActionButton(
                    icon: Icons.info_outline_rounded,
                    label: l10n.homeViewDetails.replaceAll('\n', ' ').toUpperCase(),
                    color: colors.accentPurple,
                    onTap: () {
                      if (_currentPick != null) {
                        widget.onItemTap?.call(_currentPick!.item);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Card individual para un AI Pick - Estilo Premium con backdrop
class _AIPickCard extends StatelessWidget {
  final AIPick pick;
  final bool showAIBadge;
  final bool isInWatchlist;
  final VoidCallback? onTap;

  const _AIPickCard({
    required this.pick,
    this.showAIBadge = true,
    this.isInWatchlist = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final item = pick.item;
    final imageUrl = item.backdropUrl ?? item.posterUrl ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.surfaceBorder.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colors.surface,
                    child: Icon(
                      Icons.movie_outlined,
                      size: 64,
                      color: colors.textTertiary,
                    ),
                  ),
                )
              else
                Container(
                  color: colors.surface,
                  child: Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: colors.textTertiary,
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
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.4, 0.65, 1.0],
                  ),
                ),
              ),

              // Match badge (top left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: colors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        showAIBadge ? l10n.aiPicksMatchBadge : l10n.aiPicksTrendingBadge,
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "EN LISTA" badge (top right)
              if (isInWatchlist)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.homeInList,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content (bottom)
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Genre/Type tag
                    Text(
                      item.contentType == ContentType.movie
                          ? l10n.aiPicksContentMovie
                          : l10n.aiPicksContentSeries,
                      style: AppTypography.overline.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      item.title,
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // AI Reason / Description
                    Text(
                      pick.reason,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de acción para AI Picks
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.isActive = false,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveIcon = widget.isActive && widget.activeIcon != null
        ? widget.activeIcon!
        : widget.icon;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 90,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.color.withValues(alpha: 0.2)
              : widget.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isActive
                ? widget.color.withValues(alpha: 0.4)
                : widget.color.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                color: widget.isActive ? widget.color : widget.color.withValues(alpha: 0.9),
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              widget.label,
              style: AppTypography.overline.copyWith(
                color: widget.isActive
                    ? widget.color
                    : colors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton para AI Pick Card
class _SkeletonAIPickCard extends StatefulWidget {
  final String? message;

  const _SkeletonAIPickCard({this.message});

  @override
  State<_SkeletonAIPickCard> createState() => _SkeletonAIPickCardState();
}

class _SkeletonAIPickCardState extends State<_SkeletonAIPickCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Stack(
        children: [
          // Background shimmer
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.surfaceElevated,
                  colors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          // Message in center (if provided)
          if (widget.message != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) => Opacity(
                      opacity: _animation.value,
                      child: const KinoAvatar(size: 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          // Content skeleton
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 220,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Badge skeleton
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 110,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacio cuando no hay picks
class _EmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _EmptyState({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        children: [
          const KinoMascot(size: 80),
          const SizedBox(height: 16),
          Text(
            l10n.kinoLoadingPicks,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.kinoLoadingPicksHint,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                l10n.kinoRetry,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
