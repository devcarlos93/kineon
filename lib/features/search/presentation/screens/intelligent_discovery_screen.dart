import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/entities/media_item.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../subscription/subscription.dart';
import '../../../subscription/presentation/widgets/smart_paywall_modal.dart';
import '../../../../core/widgets/kino_mascot.dart';
import '../providers/intelligent_search_provider.dart';
import '../providers/streaming_providers_provider.dart';

/// Pantalla de Intelligent Discovery
class IntelligentDiscoveryScreen extends ConsumerStatefulWidget {
  const IntelligentDiscoveryScreen({super.key});

  @override
  ConsumerState<IntelligentDiscoveryScreen> createState() =>
      _IntelligentDiscoveryScreenState();
}

class _IntelligentDiscoveryScreenState
    extends ConsumerState<IntelligentDiscoveryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _currentSuggestion = '';
  bool _suggestionsInitialized = false;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_suggestionsInitialized) {
      _rotateSuggestion();
      _suggestionsInitialized = true;
    }
  }

  void _onScroll() {
    // Cerrar teclado al hacer scroll
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _rotateSuggestion() {
    final random = Random();
    final l10n = AppLocalizations.of(context);
    final suggestions = l10n.strings.searchDiscoverySuggestions;
    _currentSuggestion = suggestions[random.nextInt(suggestions.length)];
  }

  /// Búsqueda automática mientras escribe
  void _onSearchChanged(String query) {
    ref.read(intelligentSearchProvider.notifier).search(query);
  }

  /// Búsqueda explícita (enter, voz) - igual que automática
  void _onSearchSubmit(String query) {
    _dismissKeyboard();
    _onSearchChanged(query);
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();

    if (!_speechAvailable) {
      _showSpeechNotAvailable();
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);

      // Usar idioma de preferencias regionales (ej: "es-ES" -> "es_ES")
      final regionalPrefs = ref.read(regionalPrefsProvider);
      final localeId = regionalPrefs.languageTag.replaceAll('-', '_');

      await _speech.listen(
        onResult: (result) {
          _searchController.text = result.recognizedWords;
          if (result.finalResult) {
            _onSearchSubmit(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.search,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
  }

  void _showSpeechNotAvailable() {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reconocimiento de voz no disponible'),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToDetail(MediaItem item) {
    final type = item.contentType == ContentType.tv ? 'tv' : 'movie';
    context.push('/details/$type/${item.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(intelligentSearchProvider);
    final mediaQuery = MediaQuery.of(context);

    // Pre-cargar streaming providers para que estén listos al tocar el chip
    ref.watch(streamingProvidersProvider);

    // Escuchar cuando se alcanza el límite y mostrar paywall
    ref.listen<IntelligentSearchState>(intelligentSearchProvider, (prev, next) {
      if (next.limitReached && !(prev?.limitReached ?? false)) {
        PaywallModal.show(
          context,
          endpoint: AIEndpoints.search,
          onUpgrade: () => context.push('/profile/subscription'),
        );
      }

      // Smart paywall: cuando resultados aparecen por primera vez
      final hadResults = (prev?.results.isNotEmpty ?? false);
      final hasResults = next.results.isNotEmpty && !next.isLoadingResults;
      if (!hadResults && hasResults) {
        SmartPaywallModal.maybeShow(
          context,
          ref,
          trigger: SmartPaywallTriggers.firstSearch,
        );
      }
    });

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              // Search Input
              _buildSearchInput(state),

              // Hint text
              if (state.query.isEmpty) _buildHintText(),

              // Intent summary (solo cuando hay query activa con plan)
              if (state.query.isNotEmpty && state.plan != null && !state.isLoadingPlan)
                _buildIntentSummary(state.plan!),

              // Filter Chips
              _buildFilterChips(state),

              // Content
              Expanded(
                child: _buildContent(state, mediaQuery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = context.colors;
    final subscription = ref.watch(subscriptionProvider);
    final usage = subscription.getUsage(AIEndpoints.search);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'INTELLIGENT',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.accent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Usage counter badge
                  AIUsageCounter(
                    remaining: usage.remaining,
                    total: usage.dailyLimit,
                    isPro: subscription.isPro,
                    onUpgradeTap: () => context.push('/profile/subscription'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(context).strings.searchDiscovery,
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(IntelligentSearchState state) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.surfaceBorder),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Kino icon
            KinoIcon(size: 20, mood: KinoMood.happy, color: colors.accent),
            const SizedBox(width: 12),
            // Text field
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmit,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontFamily: AppTypography.bodyMedium.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.textPrimary,
                ),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? AppLocalizations.of(context).strings.searchDiscoveryListening
                      : AppLocalizations.of(context).strings.searchDiscoveryPlaceholder,
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.bodyMedium.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _isListening ? colors.error : colors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            // Loading indicator
            if (state.isLoadingPlan)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                ),
              )
            // Listening indicator
            else if (_isListening)
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.mic_fill,
                    color: colors.error,
                    size: 22,
                  ),
                ),
              )
            // Mic button (default)
            else
              IconButton(
                onPressed: _toggleListening,
                icon: Icon(
                  CupertinoIcons.mic,
                  color: _speechAvailable ? colors.accent : colors.textTertiary,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintText() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Text(
        '${AppLocalizations.of(context).strings.searchDiscoveryTryPrefix} "$_currentSuggestion"',
        style: AppTypography.caption.copyWith(
          color: colors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildIntentSummary(SearchPlan plan) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            color: colors.accent,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              plan.intentSummary,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(IntelligentSearchState state) {
    final l10n = AppLocalizations.of(context);
    final genreMap = l10n.strings.genreBadgeNames;

    // Solo mostrar labels del plan de IA cuando hay query activa
    final showPlanLabels = state.query.isNotEmpty && state.plan != null;

    // Determinar label de género
    String genreLabel;
    bool genreIsUserSet = state.selectedGenreIds != null;
    bool genreActive;
    if (state.selectedGenreIds != null && state.selectedGenreIds!.isNotEmpty) {
      genreLabel = genreMap[state.selectedGenreIds!.first] ?? l10n.strings.searchFilterGenre;
      genreActive = true;
    } else if (showPlanLabels) {
      genreLabel = state.plan!.ui.genreLabel;
      genreActive = state.plan!.discover.withGenres.isNotEmpty;
    } else {
      genreLabel = l10n.strings.searchFilterGenre;
      genreActive = false;
    }

    // Determinar label de mood
    String moodLabel;
    bool moodIsUserSet = state.selectedMood != null;
    bool moodActive;
    if (state.selectedMood != null) {
      moodLabel = state.selectedMood!;
      moodActive = true;
    } else if (showPlanLabels && state.plan!.ui.moodLabel != null) {
      moodLabel = state.plan!.ui.moodLabel!;
      moodActive = true;
    } else {
      moodLabel = l10n.strings.searchFilterMood;
      moodActive = false;
    }

    // Runtime
    bool runtimeIsUserSet = state.selectedRuntime != null;
    String runtimeLabel;
    bool runtimeActive;
    if (runtimeIsUserSet) {
      runtimeLabel = '< ${state.selectedRuntime}m';
      runtimeActive = true;
    } else if (showPlanLabels && state.plan!.ui.runtimeLabel != null) {
      runtimeLabel = state.plan!.ui.runtimeLabel!;
      runtimeActive = true;
    } else {
      runtimeLabel = l10n.strings.searchFilterRuntime;
      runtimeActive = false;
    }

    // Year
    bool yearIsUserSet = state.selectedYear != null;
    String yearLabel;
    bool yearActive;
    if (yearIsUserSet) {
      yearLabel = state.selectedYear!;
      yearActive = true;
    } else if (showPlanLabels && state.plan!.ui.yearLabel != null) {
      yearLabel = state.plan!.ui.yearLabel!;
      yearActive = true;
    } else {
      yearLabel = l10n.strings.searchFilterYear;
      yearActive = false;
    }

    // Streaming platform
    bool streamingIsUserSet = state.selectedWatchProviders != null && state.selectedWatchProviders!.isNotEmpty;
    String streamingLabel;
    bool streamingActive;
    if (streamingIsUserSet) {
      final count = state.selectedWatchProviders!.length;
      if (count == 1) {
        // Show the provider name if we can resolve it
        final providers = ref.watch(streamingProvidersProvider).valueOrNull ?? [];
        final match = providers.where((p) => p.providerId == state.selectedWatchProviders!.first);
        streamingLabel = match.isNotEmpty ? match.first.providerName : l10n.strings.searchFilterStreaming;
      } else {
        streamingLabel = l10n.strings.searchFilterStreamingCount(count);
      }
      streamingActive = true;
    } else {
      streamingLabel = l10n.strings.searchFilterStreaming;
      streamingActive = false;
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(
            label: genreLabel,
            isActive: genreActive,
            isUserOverride: genreIsUserSet,
            onTap: () => _showGenrePicker(state),
            onClear: genreIsUserSet ? () {
              ref.read(intelligentSearchProvider.notifier).setGenreFilter(null);
            } : null,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: streamingLabel,
            isActive: streamingActive,
            isUserOverride: streamingIsUserSet,
            onTap: () => _showStreamingPicker(state),
            onClear: streamingIsUserSet ? () {
              ref.read(intelligentSearchProvider.notifier).setWatchProviderFilter(null);
            } : null,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: moodLabel,
            isActive: moodActive,
            isUserOverride: moodIsUserSet,
            onTap: () => _showMoodPicker(state),
            onClear: moodIsUserSet ? () {
              ref.read(intelligentSearchProvider.notifier).setMoodFilter(null);
            } : null,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: runtimeLabel,
            isActive: runtimeActive,
            isUserOverride: runtimeIsUserSet,
            onTap: () => _showRuntimePicker(state),
            onClear: runtimeIsUserSet ? () {
              ref.read(intelligentSearchProvider.notifier).setRuntimeFilter(null);
            } : null,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: yearLabel,
            isActive: yearActive,
            isUserOverride: yearIsUserSet,
            onTap: () => _showYearPicker(state),
            onClear: yearIsUserSet ? () {
              ref.read(intelligentSearchProvider.notifier).setYearFilter(null);
            } : null,
          ),
        ],
      ),
    );
  }

  // ── Filter pickers ──────────────────────────────────────────────────────

  void _showGenrePicker(IntelligentSearchState state) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final genreMap = l10n.strings.genreBadgeNames;

    // Géneros principales de películas (excluir duplicados de TV)
    const mainGenreIds = [28, 12, 16, 35, 80, 99, 18, 10751, 14, 36, 27, 10402, 9648, 10749, 878, 53, 10752, 37];
    final genreNames = mainGenreIds
        .where((id) => genreMap.containsKey(id))
        .map((id) => genreMap[id]!)
        .toList();

    final selectedName = state.selectedGenreIds != null && state.selectedGenreIds!.isNotEmpty
        ? genreMap[state.selectedGenreIds!.first]
        : null;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterGenre,
        options: genreNames,
        selectedValue: selectedName,
        onSelect: (value) {
          if (value != null) {
            final genreId = genreMap.entries.firstWhere((e) => e.value == value).key;
            ref.read(intelligentSearchProvider.notifier).setGenreFilter([genreId]);
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(intelligentSearchProvider.notifier).setGenreFilter(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showMoodPicker(IntelligentSearchState state) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final moods = l10n.strings.searchFilterMoodOptions;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterMood,
        options: moods,
        selectedValue: state.selectedMood,
        onSelect: (value) {
          ref.read(intelligentSearchProvider.notifier).setMoodFilter(value);
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(intelligentSearchProvider.notifier).setMoodFilter(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showRuntimePicker(IntelligentSearchState state) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final runtimes = ['60', '90', '120', '150', '180'];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterRuntime,
        options: runtimes.map((r) => '< $r min').toList(),
        selectedValue: state.selectedRuntime != null ? '< ${state.selectedRuntime} min' : null,
        onSelect: (value) {
          if (value != null) {
            final minutes = value.replaceAll(RegExp(r'[^0-9]'), '');
            ref.read(intelligentSearchProvider.notifier).setRuntimeFilter(minutes);
          }
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(intelligentSearchProvider.notifier).setRuntimeFilter(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showYearPicker(IntelligentSearchState state) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final years = List.generate(50, (i) => (currentYear - i).toString());

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _FilterModal(
        title: l10n.strings.searchFilterYear,
        options: years,
        selectedValue: state.selectedYear,
        onSelect: (value) {
          ref.read(intelligentSearchProvider.notifier).setYearFilter(value);
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(intelligentSearchProvider.notifier).setYearFilter(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showStreamingPicker(IntelligentSearchState state) {
    HapticFeedback.lightImpact();

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _StreamingPickerSheet(
        selectedIds: state.selectedWatchProviders ?? [],
        onApply: (ids) {
          ref.read(intelligentSearchProvider.notifier).setWatchProviderFilter(
            ids.isNotEmpty ? ids : null,
          );
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(intelligentSearchProvider.notifier).setWatchProviderFilter(null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildContent(IntelligentSearchState state, MediaQueryData mediaQuery) {
    // Empty state (no query AND no active filters)
    if (state.query.isEmpty && !state.hasAnyFilter) {
      return _buildEmptyState();
    }

    // Loading
    if (state.isLoading && state.results.isEmpty) {
      return _buildLoadingState();
    }

    // Error
    if (state.error != null && state.results.isEmpty) {
      return _buildErrorState(state.error!);
    }

    // Results
    if (state.hasResults) {
      return _buildResults(state, mediaQuery);
    }

    // No results (only show if we actually searched)
    if (state.query.isNotEmpty || state.hasAnyFilter) {
      return _buildNoResultsState();
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KinoIcon(size: 64, mood: KinoMood.greeting),
            const SizedBox(height: 24),
            Text(
              l10n.strings.searchDiscoveryEmptyTitle,
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.strings.searchDiscoveryEmptySubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.accent),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).strings.searchDiscoveryLoading,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: colors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).strings.searchDiscoveryErrorTitle,
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.film,
              color: colors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).strings.searchDiscoveryNoResultsTitle,
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).strings.searchDiscoveryNoResultsSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(IntelligentSearchState state, MediaQueryData mediaQuery) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: AI Recommended + Match %
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).strings.searchDiscoveryAiRecommended,
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.plan != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${state.plan!.matchPercent}% ${AppLocalizations.of(context).strings.searchDiscoveryMatch}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Grid de resultados
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 100 + mediaQuery.padding.bottom,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final item = state.results[index];
              return _DiscoveryCard(
                item: item,
                onTap: () => _navigateToDetail(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Chip de filtro con soporte para clear y diferenciación AI vs usuario
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isUserOverride;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isActive,
    this.isUserOverride = false,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Colores diferenciados: usuario = accent sólido, AI = accent sutil
    final chipColor = isUserOverride
        ? colors.accent.withValues(alpha: 0.25)
        : isActive
            ? colors.accent.withValues(alpha: 0.12)
            : colors.surface;
    final borderColor = isUserOverride
        ? colors.accent.withValues(alpha: 0.6)
        : isActive
            ? colors.accent.withValues(alpha: 0.3)
            : colors.surfaceBorder;
    final textColor = isActive ? colors.accent : colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          left: 14,
          right: onClear != null ? 8 : 14,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClear!();
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 10,
                    color: colors.accent,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_down,
                size: 14,
                color: isActive ? colors.accent : colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card de película/serie para Discovery
class _DiscoveryCard extends ConsumerWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _DiscoveryCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final posterUrl = item.posterPath != null
        ? '${AppConstants.tmdbPosterMedium}${item.posterPath}'
        : null;

    // Determinar género principal para el badge
    final genreName = _getGenreName(context, item.genreIds.isNotEmpty ? item.genreIds.first : 0);

    // Obtener estado de biblioteca para este item
    final mediaStateAsync = ref.watch(
      mediaStateProvider(MediaStateParams(
        tmdbId: item.id,
        contentType: item.contentType,
      )),
    );

    final isFavorite = mediaStateAsync.valueOrNull?.isFavorite ?? false;
    final isInWatchlist = mediaStateAsync.valueOrNull?.isInWatchlist ?? false;
    final isWatched = mediaStateAsync.valueOrNull?.isWatched ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster con acciones
          Expanded(
            child: Stack(
              children: [
                // Poster
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (_, __) => Container(
                              color: colors.surfaceElevated,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.accent,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(colors),
                          )
                        : _buildPlaceholder(colors),
                  ),
                ),

                // Quick action buttons - solo mostrar si hay algún estado activo
                if (isFavorite || isInWatchlist || isWatched)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        if (isFavorite)
                          _QuickActionButton(
                            icon: CupertinoIcons.heart_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .toggleFavorite(item.id, item.contentType);
                            },
                          ),
                        if (isFavorite && (isInWatchlist || isWatched))
                          const SizedBox(height: 8),
                        if (isInWatchlist)
                          _QuickActionButton(
                            icon: CupertinoIcons.bookmark_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .removeFromWatchlist(item.id, item.contentType);
                            },
                          ),
                        if (isInWatchlist && isWatched) const SizedBox(height: 8),
                        if (isWatched)
                          _QuickActionButton(
                            icon: CupertinoIcons.eye_fill,
                            isActive: true,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(libraryActionsProvider.notifier)
                                  .removeFromWatched(item.id, item.contentType);
                            },
                          ),
                      ],
                    ),
                  ),

                // Genre badge + runtime (abajo izquierda)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      // Genre badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          genreName.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textOnAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Runtime (placeholder - necesita datos de detail)
                      Text(
                        item.releaseDate != null
                            ? item.releaseDate!.split('-').first
                            : '',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle (director/year placeholder)
          Text(
            item.releaseDate?.split('-').first ?? '',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(KineonColors colors) {
    return Container(
      color: colors.surfaceElevated,
      child: Center(
        child: Icon(
          CupertinoIcons.film,
          color: colors.textTertiary,
          size: 40,
        ),
      ),
    );
  }

  String _getGenreName(BuildContext context, int genreId) {
    final genreMap = AppLocalizations.of(context).strings.genreBadgeNames;
    return genreMap[genreId] ?? 'MOVIE';
  }
}

/// Botón de acción rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent
              : Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? AppColors.textOnAccent : Colors.white,
        ),
      ),
    );
  }
}

/// Modal de selección de filtro
class _FilterModal extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelect;
  final VoidCallback onClear;

  const _FilterModal({
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.h4,
                ),
                if (selectedValue != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onClear,
                    child: Text(
                      l10n.strings.searchClear,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == selectedValue;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(option);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.accent.withValues(alpha: 0.15)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colors.accent.withValues(alpha: 0.4)
                            : colors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? colors.accent
                                : colors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            CupertinoIcons.checkmark,
                            color: colors.accent,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
    );
  }
}

/// Bottom sheet de selección de plataformas de streaming con logos.
/// Es ConsumerStatefulWidget para observar el provider internamente y
/// mostrar loading / error / datos sin depender del caller.
class _StreamingPickerSheet extends ConsumerStatefulWidget {
  final List<int> selectedIds;
  final ValueChanged<List<int>> onApply;
  final VoidCallback onClear;

  const _StreamingPickerSheet({
    required this.selectedIds,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<_StreamingPickerSheet> createState() => _StreamingPickerSheetState();
}

class _StreamingPickerSheetState extends ConsumerState<_StreamingPickerSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.selectedIds);
  }

  void _toggle(int id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final providersAsync = ref.watch(streamingProvidersProvider);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.strings.searchFilterStreaming,
                    style: AppTypography.h4,
                  ),
                  if (_selected.isNotEmpty)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onClear,
                      child: Text(
                        l10n.strings.searchClear,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content: loading / error / grid
            Flexible(
              child: providersAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: colors.accent),
                  ),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.exclamationmark_circle, color: colors.error, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          l10n.strings.stateErrorGenericMessage,
                          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          onPressed: () => ref.invalidate(streamingProvidersProvider),
                          child: Text(
                            l10n.strings.commonRetry,
                            style: AppTypography.labelMedium.copyWith(color: colors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (providers) => GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final isSelected = _selected.contains(provider.providerId);

                    return GestureDetector(
                      onTap: () => _toggle(provider.providerId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.accent.withValues(alpha: 0.15)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? colors.accent.withValues(alpha: 0.6)
                                : colors.surfaceBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: provider.logoUrl,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 32,
                                  height: 32,
                                  color: colors.surface,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 32,
                                  height: 32,
                                  color: colors.surface,
                                  child: Icon(
                                    CupertinoIcons.tv,
                                    color: colors.textTertiary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Name
                            Expanded(
                              child: Text(
                                provider.providerName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isSelected ? colors.accent : colors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Checkmark
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: colors.accent,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => widget.onApply(_selected.toList()),
                  child: Text(
                    l10n.strings.searchFilterStreamingApply,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textOnAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
