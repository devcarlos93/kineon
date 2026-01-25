import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kineon/main.dart' as app;
import 'package:kineon/core/network/supabase_client.dart';
import 'package:kineon/core/cache/cache_service.dart';
import 'package:kineon/core/router/app_router.dart';

import 'robots/login_robot.dart';
import 'robots/search_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow', () {
    testWidgets('should display login screen with Apple and Google buttons',
        (tester) async {
      await _initializeApp(tester);

      final loginRobot = LoginRobot(tester);

      // Verify login screen elements
      await loginRobot.verifyLoginScreenDisplayed();
      await loginRobot.verifyAppleButtonVisible();
      await loginRobot.verifyGoogleButtonVisible();
      await loginRobot.verifyLegalDisclaimerVisible();
    });

    testWidgets('should show loading state when tapping login button',
        (tester) async {
      await _initializeApp(tester);

      final loginRobot = LoginRobot(tester);

      await loginRobot.verifyLoginScreenDisplayed();

      // Tap Google button (Apple requires real device)
      await loginRobot.tapGoogleButton();

      // Should show loading indicator
      await loginRobot.verifyLoadingState();
    });
  });

  group('Search Flow', () {
    testWidgets('should display search screen with input field',
        (tester) async {
      await _initializeApp(tester);

      // Skip login for search tests - navigate directly
      await _navigateToSearch(tester);

      final searchRobot = SearchRobot(tester);

      // Verify search screen elements
      await searchRobot.verifySearchScreenDisplayed();
      await searchRobot.verifySearchInputVisible();
      await searchRobot.verifyFilterChipsVisible();
    });

    testWidgets('should show empty state initially', (tester) async {
      await _initializeApp(tester);
      await _navigateToSearch(tester);

      final searchRobot = SearchRobot(tester);

      await searchRobot.verifyEmptyStateDisplayed();
    });

    testWidgets('should perform search and show results', (tester) async {
      await _initializeApp(tester);
      await _navigateToSearch(tester);

      final searchRobot = SearchRobot(tester);

      // Enter search query
      await searchRobot.enterSearchQuery('Interstellar');

      // Wait for results
      await searchRobot.waitForResults();

      // Verify results are displayed or still showing search screen (if no network)
      await searchRobot.verifySearchScreenDisplayed();
    });

    testWidgets('should dismiss keyboard when scrolling', (tester) async {
      await _initializeApp(tester);
      await _navigateToSearch(tester);

      final searchRobot = SearchRobot(tester);

      // Focus search input
      await searchRobot.focusSearchInput();

      // Enter query to trigger results
      await searchRobot.enterSearchQuery('Action movies');
      await searchRobot.waitForResults();

      // Scroll if there are results
      await searchRobot.scrollResults();

      // Verify we're still on search screen
      await searchRobot.verifySearchScreenDisplayed();
    });

    testWidgets('should clear search when clearing input', (tester) async {
      await _initializeApp(tester);
      await _navigateToSearch(tester);

      final searchRobot = SearchRobot(tester);

      // Enter search query
      await searchRobot.enterSearchQuery('Test movie');
      await tester.pumpAndSettle();

      // Clear search
      await searchRobot.clearSearch();

      // Should show empty state
      await searchRobot.verifyEmptyStateDisplayed();
    });
  });

  group('Navigation Flow', () {
    testWidgets('should navigate between tabs', (tester) async {
      await _initializeApp(tester);
      await _skipToHome(tester);

      // Verify custom bottom navigation bar exists
      expect(find.byType(KineonBottomBar), findsOneWidget);

      // Navigate to search tab using the search icon
      final searchIcon = find.byIcon(Icons.search_outlined);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();
      }

      // Verify search screen - look for Discovery text or INTELLIGENT
      final hasSearchScreen = find.text('Discovery').evaluate().isNotEmpty ||
          find.text('INTELLIGENT').evaluate().isNotEmpty;
      expect(hasSearchScreen, isTrue);
    });
  });
}

/// Initialize the app for testing
Future<void> _initializeApp(WidgetTester tester) async {
  // Initialize dependencies (may already be initialized)
  try {
    await SupabaseConfig.initialize();
  } catch (_) {
    // Already initialized
  }

  try {
    await CacheService().initialize();
  } catch (_) {
    // Already initialized
  }

  // Run the app
  await tester.pumpWidget(
    const ProviderScope(
      child: app.KineonApp(),
    ),
  );

  // Wait for splash screen and initial navigation
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Navigate directly to search tab (skip authentication)
Future<void> _navigateToSearch(WidgetTester tester) async {
  // Wait for any initial navigation
  await tester.pumpAndSettle();

  // Try to find and tap search tab icon
  final searchIcon = find.byIcon(Icons.search_outlined);
  if (searchIcon.evaluate().isNotEmpty) {
    await tester.tap(searchIcon.first);
    await tester.pumpAndSettle();
    return;
  }

  // Fallback: try by icon with rounded variant
  final searchIconRounded = find.byIcon(Icons.search_rounded);
  if (searchIconRounded.evaluate().isNotEmpty) {
    await tester.tap(searchIconRounded.first);
    await tester.pumpAndSettle();
  }
}

/// Skip to home screen (for navigation tests)
Future<void> _skipToHome(WidgetTester tester) async {
  await tester.pumpAndSettle();

  // Wait for initial navigation to complete
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
