import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold, ScaffoldMessenger, SnackBar, SnackBarBehavior, RoundedRectangleBorder;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_search_data.dart';
import '../widgets/filter_chips.dart';
import '../widgets/poster_grid_item.dart';
import '../widgets/search_bar_premium.dart';
import '../widgets/search_states.dart';

/// Pantalla de búsqueda inteligente con diseño Stitch
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasSearched = false;
  SearchFilter _filter = const SearchFilter();
  List<MockSearchResult> _results = [];
  String _currentSuggestion = searchSuggestions.first;
  int _suggestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _rotateSuggestion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _rotateSuggestion() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _searchController.text.isEmpty) {
        setState(() {
          _suggestionIndex = (_suggestionIndex + 1) % searchSuggestions.length;
          _currentSuggestion = searchSuggestions[_suggestionIndex];
        });
        _rotateSuggestion();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simular búsqueda con IA
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Usar mock results
    setState(() {
      _results = List.from(mockAIRecommendedResults);
      _isLoading = false;
    });
  }

  void _onFilterChanged(SearchFilter newFilter) {
    setState(() => _filter = newFilter);
    if (_hasSearched) {
      _performSearch(_searchController.text);
    }
  }

  void _toggleFavorite(int index) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    setState(() {
      _results[index] = _results[index].copyWith(
        isFavorite: !_results[index].isFavorite,
      );
    });
    _showSnackBar(
      _results[index].isFavorite
          ? l10n.strings.searchAddedFavorite
          : l10n.strings.searchRemovedFavorite,
      CupertinoIcons.heart_fill,
      const Color(0xFFFF4D6D),
    );
  }

  void _toggleWatchlist(int index) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    HapticFeedback.mediumImpact();
    setState(() {
      _results[index] = _results[index].copyWith(
        inWatchlist: !_results[index].inWatchlist,
      );
    });
    _showSnackBar(
      _results[index].inWatchlist
          ? l10n.strings.searchAddedWatchlist
          : l10n.strings.searchRemovedWatchlist,
      CupertinoIcons.bookmark_fill,
      AppColors.accentLime,
    );
  }

  void _toggleSeen(int index) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    HapticFeedback.mediumImpact();
    setState(() {
      _results[index] = _results[index].copyWith(
        isSeen: !_results[index].isSeen,
      );
    });
    _showSnackBar(
      _results[index].isSeen
          ? l10n.strings.searchMarkedSeen
          : l10n.strings.searchUnmarkedSeen,
      CupertinoIcons.eye_fill,
      colors.accent,
    );
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String? get _avatarUrl {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['avatar_url'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SearchHeader(
              avatarUrl: _avatarUrl,
              hasNotifications: true,
              onAvatarTap: () {
                // TODO: Go to profile
              },
              onNotificationsTap: () {
                // TODO: Show notifications
              },
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarPremium(
                controller: _searchController,
                hintText: l10n.strings.searchHint,
                suggestionText: _currentSuggestion,
                isLoading: _isLoading,
                onChanged: (value) {
                  if (value.length > 2) {
                    _performSearch(value);
                  } else if (value.isEmpty) {
                    setState(() {
                      _hasSearched = false;
                      _results = [];
                    });
                  }
                },
                onSubmitted: _performSearch,
                onClear: () {
                  setState(() {
                    _hasSearched = false;
                    _results = [];
                  });
                },
                onMicTap: () {
                  // TODO: Voice search
                  HapticFeedback.lightImpact();
                },
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 20),

            // Filter chips
            FilterChipsRow(
              filter: _filter,
              onFilterChanged: _onFilterChanged,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // Results
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Initial state
    if (!_hasSearched) {
      return const SearchEmptyState(isInitial: true)
          .animate()
          .fadeIn(delay: 300.ms, duration: 400.ms);
    }

    // Loading
    if (_isLoading) {
      return const ResultsGridSkeleton();
    }

    // No results
    if (_results.isEmpty) {
      return const SearchEmptyState(isInitial: false)
          .animate()
          .fadeIn(duration: 400.ms);
    }

    // Results
    return Column(
      children: [
        // Results header
        ResultsHeader(
          matchPercentage: _results.isNotEmpty ? _results.first.matchPercentage : null,
        ).animate().fadeIn(duration: 400.ms),

        // Grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return PosterGridItem(
                result: result,
                onTap: () => context.push('/details/movie/${result.id}'),
                onFavoriteTap: () => _toggleFavorite(index),
                onWatchlistTap: () => _toggleWatchlist(index),
                onSeenTap: () => _toggleSeen(index),
              ).animate().fadeIn(
                    delay: (index * 80).ms,
                    duration: 400.ms,
                  );
            },
          ),
        ),
      ],
    );
  }
}
