import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de autenticación con Apple
///
/// Usa sign_in_with_apple para login nativo y luego
/// autentica con Supabase usando el ID token.
class AppleAuthService {
  final SupabaseClient _supabase;

  AppleAuthService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Genera un nonce aleatorio para seguridad
  String _generateRawNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Hashea el nonce con SHA256
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Inicia sesión con Apple de forma nativa
  ///
  /// Retorna la sesión de Supabase si es exitoso.
  /// Lanza [AppleAuthException] si hay error.
  Future<AuthResponse> signIn() async {
    try {
      // Generar nonce para seguridad
      final rawNonce = _generateRawNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // 1. Login nativo con Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;

      if (idToken == null) {
        throw AppleAuthException(
          code: 'no_id_token',
          message: 'No se pudo obtener el token de Apple',
        );
      }

      // 2. Autenticar con Supabase usando el ID token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.session == null) {
        throw AppleAuthException(
          code: 'no_session',
          message: 'No se pudo crear la sesión',
        );
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AppleAuthException(
          code: 'cancelled',
          message: 'Inicio de sesión cancelado',
        );
      }
      throw AppleAuthException(
        code: 'apple_error',
        message: e.message,
      );
    } on AuthException catch (e) {
      throw AppleAuthException(
        code: 'supabase_error',
        message: e.message,
      );
    } catch (e) {
      if (e is AppleAuthException) rethrow;

      throw AppleAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }
}

/// Excepción personalizada para errores de Apple Auth
class AppleAuthException implements Exception {
  final String code;
  final String message;

  AppleAuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AppleAuthException: [$code] $message';
}

// =====================================================
// PROVIDERS
// =====================================================

/// Provider del servicio de Apple Auth
final appleAuthServiceProvider = Provider<AppleAuthService>((ref) {
  return AppleAuthService();
});
