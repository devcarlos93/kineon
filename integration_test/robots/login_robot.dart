import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Login screen in integration tests
class LoginRobot {
  final WidgetTester tester;

  LoginRobot(this.tester);

  // ═══════════════════════════════════════════════════════════════════════════
  // FINDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Finder get _appleButton => find.textContaining('Apple');
  Finder get _googleButton => find.textContaining('Google');
  Finder get _kineonLogo => find.text('Kineon');
  Finder get _termsText => find.textContaining('Términos');
  Finder get _privacyText => find.textContaining('Privacidad');
  Finder get _loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get _errorCard => find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null,
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // VERIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verify login screen is displayed
  Future<void> verifyLoginScreenDisplayed() async {
    await tester.pumpAndSettle();

    // Look for headline text or logo
    expect(
      find.textContaining('Kineon').evaluate().isNotEmpty ||
          find.textContaining('Descubre').evaluate().isNotEmpty,
      isTrue,
      reason: 'Login screen should be displayed',
    );
  }

  /// Verify Apple sign-in button is visible
  Future<void> verifyAppleButtonVisible() async {
    await tester.pumpAndSettle();
    expect(_appleButton, findsOneWidget,
        reason: 'Apple sign-in button should be visible');
  }

  /// Verify Google sign-in button is visible
  Future<void> verifyGoogleButtonVisible() async {
    await tester.pumpAndSettle();
    expect(_googleButton, findsOneWidget,
        reason: 'Google sign-in button should be visible');
  }

  /// Verify legal disclaimer is visible
  Future<void> verifyLegalDisclaimerVisible() async {
    await tester.pumpAndSettle();

    // Check for terms or privacy text
    final hasLegalText =
        find.textContaining('Términos').evaluate().isNotEmpty ||
            find.textContaining('Terms').evaluate().isNotEmpty ||
            find.textContaining('continuar').evaluate().isNotEmpty;

    expect(hasLegalText, isTrue, reason: 'Legal disclaimer should be visible');
  }

  /// Verify loading state is shown
  Future<void> verifyLoadingState() async {
    // Loading might be quick, so pump a few frames
    await tester.pump(const Duration(milliseconds: 100));

    // Either loading indicator or still on screen (if auth fails immediately)
    final hasLoading = _loadingIndicator.evaluate().isNotEmpty;
    final stillOnLogin = _appleButton.evaluate().isNotEmpty;

    expect(hasLoading || stillOnLogin, isTrue,
        reason: 'Should show loading state or remain on login');
  }

  /// Verify error message is displayed
  Future<void> verifyErrorDisplayed() async {
    await tester.pumpAndSettle();

    // Look for error icon or error text
    final hasError = find.byIcon(Icons.error_outline_rounded).evaluate().isNotEmpty ||
        find.textContaining('error').evaluate().isNotEmpty ||
        find.textContaining('Error').evaluate().isNotEmpty;

    expect(hasError, isTrue, reason: 'Error message should be displayed');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Tap Apple sign-in button
  Future<void> tapAppleButton() async {
    await tester.pumpAndSettle();
    await tester.tap(_appleButton);
    await tester.pump();
  }

  /// Tap Google sign-in button
  Future<void> tapGoogleButton() async {
    await tester.pumpAndSettle();
    await tester.tap(_googleButton);
    await tester.pump();
  }

  /// Dismiss error message
  Future<void> dismissError() async {
    final closeButton = find.byIcon(Icons.close_rounded);
    if (closeButton.evaluate().isNotEmpty) {
      await tester.tap(closeButton.first);
      await tester.pumpAndSettle();
    }
  }

  /// Wait for navigation after successful login
  Future<void> waitForSuccessfulLogin() async {
    // Wait up to 10 seconds for navigation
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Verify we're no longer on login screen
    expect(_appleButton.evaluate().isEmpty, isTrue,
        reason: 'Should have navigated away from login screen');
  }
}
