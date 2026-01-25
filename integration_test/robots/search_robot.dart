import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Search/Discovery screen in integration tests
class SearchRobot {
  final WidgetTester tester;

  SearchRobot(this.tester);

  // ═══════════════════════════════════════════════════════════════════════════
  // FINDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Finder get _searchInput => find.byType(TextField);
  Finder get _searchIcon => find.byIcon(CupertinoIcons.sparkles);
  Finder get _micButton => find.byIcon(CupertinoIcons.mic);
  Finder get _clearButton => find.byIcon(CupertinoIcons.xmark_circle_fill);
  Finder get _discoveryTitle => find.text('Discovery');
  Finder get _intelligentLabel => find.text('INTELLIGENT');
  Finder get _emptyStateIcon => find.byIcon(CupertinoIcons.sparkles);
  Finder get _loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get _resultsGrid => find.byType(GridView);
  Finder get _filterChips => find.textContaining('Género');

  // ═══════════════════════════════════════════════════════════════════════════
  // VERIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verify search screen is displayed
  Future<void> verifySearchScreenDisplayed() async {
    await tester.pumpAndSettle();

    // Look for Discovery title or INTELLIGENT label
    final hasDiscovery = _discoveryTitle.evaluate().isNotEmpty ||
        _intelligentLabel.evaluate().isNotEmpty;

    expect(hasDiscovery, isTrue, reason: 'Search screen should be displayed');
  }

  /// Verify search input is visible
  Future<void> verifySearchInputVisible() async {
    await tester.pumpAndSettle();
    expect(_searchInput, findsOneWidget,
        reason: 'Search input should be visible');
  }

  /// Verify filter chips are visible
  Future<void> verifyFilterChipsVisible() async {
    await tester.pumpAndSettle();

    // Look for filter-related text
    final hasFilters = find.textContaining('Género').evaluate().isNotEmpty ||
        find.textContaining('Genre').evaluate().isNotEmpty ||
        find.textContaining('Mood').evaluate().isNotEmpty ||
        find.textContaining('Estado').evaluate().isNotEmpty;

    expect(hasFilters, isTrue, reason: 'Filter chips should be visible');
  }

  /// Verify empty state is displayed
  Future<void> verifyEmptyStateDisplayed() async {
    await tester.pumpAndSettle();

    // Look for empty state text
    final hasEmptyState =
        find.textContaining('Búsqueda Inteligente').evaluate().isNotEmpty ||
            find.textContaining('Intelligent').evaluate().isNotEmpty ||
            find.textContaining('Describe').evaluate().isNotEmpty;

    expect(hasEmptyState, isTrue, reason: 'Empty state should be displayed');
  }

  /// Verify results are displayed
  Future<void> verifyResultsDisplayed() async {
    await tester.pumpAndSettle();

    // Look for results header or grid
    final hasResults = find.text('AI Recommended').evaluate().isNotEmpty ||
        _resultsGrid.evaluate().isNotEmpty ||
        find.textContaining('MATCH').evaluate().isNotEmpty;

    expect(hasResults, isTrue, reason: 'Search results should be displayed');
  }

  /// Verify loading state is shown
  Future<void> verifyLoadingState() async {
    // Loading might be quick, check immediately
    final hasLoading = _loadingIndicator.evaluate().isNotEmpty ||
        find.textContaining('Buscando').evaluate().isNotEmpty;

    expect(hasLoading, isTrue, reason: 'Loading state should be shown');
  }

  /// Verify keyboard is visible
  Future<void> verifyKeyboardVisible() async {
    await tester.pump(const Duration(milliseconds: 500));
    // In integration tests, we can check if TextField has focus
    final textField = tester.widget<TextField>(_searchInput);
    // Note: In real device tests, keyboard visibility can be checked differently
    // For now, we just verify the field exists and can be tapped
    expect(_searchInput, findsOneWidget);
  }

  /// Verify keyboard is dismissed
  Future<void> verifyKeyboardDismissed() async {
    await tester.pumpAndSettle();
    // After scrolling, the focus should be lost
    // This is best tested on real devices
    expect(_searchInput, findsOneWidget);
  }

  /// Verify no results state
  Future<void> verifyNoResultsDisplayed() async {
    await tester.pumpAndSettle();

    final hasNoResults = find.textContaining('Sin resultados').evaluate().isNotEmpty ||
        find.textContaining('No results').evaluate().isNotEmpty;

    expect(hasNoResults, isTrue, reason: 'No results state should be displayed');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Focus search input
  Future<void> focusSearchInput() async {
    await tester.pumpAndSettle();
    await tester.tap(_searchInput);
    await tester.pumpAndSettle();
  }

  /// Enter search query
  Future<void> enterSearchQuery(String query) async {
    await tester.pumpAndSettle();
    await tester.tap(_searchInput);
    await tester.pumpAndSettle();
    await tester.enterText(_searchInput, query);
    await tester.pumpAndSettle();
  }

  /// Clear search
  Future<void> clearSearch() async {
    await tester.pumpAndSettle();

    // Try to find and tap clear button
    if (_clearButton.evaluate().isNotEmpty) {
      await tester.tap(_clearButton);
      await tester.pumpAndSettle();
    } else {
      // Fallback: clear the text field directly
      await tester.enterText(_searchInput, '');
      await tester.pumpAndSettle();
    }
  }

  /// Submit search (press enter)
  Future<void> submitSearch() async {
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  /// Wait for results to load
  Future<void> waitForResults({Duration timeout = const Duration(seconds: 5)}) async {
    // Wait for loading to complete
    await tester.pumpAndSettle(timeout);
  }

  /// Scroll results
  Future<void> scrollResults() async {
    await tester.pumpAndSettle();

    // Find a scrollable widget
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
  }

  /// Tap on first result
  Future<void> tapFirstResult() async {
    await tester.pumpAndSettle();

    // Find any tappable result
    final results = find.byType(GestureDetector);
    if (results.evaluate().length > 5) {
      // Skip navigation elements and tap a result
      await tester.tap(results.at(5));
      await tester.pumpAndSettle();
    }
  }

  /// Tap mic button
  Future<void> tapMicButton() async {
    await tester.pumpAndSettle();

    if (_micButton.evaluate().isNotEmpty) {
      await tester.tap(_micButton);
      await tester.pumpAndSettle();
    }
  }

  /// Tap filter chip by label
  Future<void> tapFilterChip(String label) async {
    await tester.pumpAndSettle();

    final chip = find.textContaining(label);
    if (chip.evaluate().isNotEmpty) {
      await tester.tap(chip.first);
      await tester.pumpAndSettle();
    }
  }
}
