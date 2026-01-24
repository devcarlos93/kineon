import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de autenticación con Google
///
/// Usa google_sign_in para login nativo y luego
/// autentica con Supabase usando el ID token.
class GoogleAuthService {
  // iOS Client ID de Google Cloud Console
  static const String _iosClientId =
      '445553999593-nrc2p0o7bhq1vfllh6dbr48ppfp0sn78.apps.googleusercontent.com';

  // Web Client ID (para Supabase - configurado en Supabase Dashboard)
  static const String _webClientId =
      '445553999593-hs4b8ev09fs73i2ls9bdmvtrv4koh3cf.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn;
  final SupabaseClient _supabase;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    SupabaseClient? supabase,
  })  : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: _iosClientId,
              serverClientId: _webClientId,
            ),
        _supabase = supabase ?? Supabase.instance.client;

  /// Inicia sesión con Google de forma nativa
  ///
  /// Retorna la sesión de Supabase si es exitoso.
  /// Lanza [GoogleAuthException] si hay error.
  Future<AuthResponse> signIn() async {
    try {
      // 1. Login nativo con Google
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw GoogleAuthException(
          code: 'cancelled',
          message: 'Inicio de sesión cancelado',
        );
      }

      // 2. Obtener tokens de autenticación
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw GoogleAuthException(
          code: 'no_id_token',
          message: 'No se pudo obtener el token de Google',
        );
      }

      // 3. Autenticar con Supabase usando el ID token
      // Nota: No pasar nonce ya que Google Sign In nativo no lo incluye en el token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session == null) {
        throw GoogleAuthException(
          code: 'no_session',
          message: 'No se pudo crear la sesión',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw GoogleAuthException(
        code: 'supabase_error',
        message: e.message,
      );
    } catch (e) {
      if (e is GoogleAuthException) rethrow;

      throw GoogleAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  /// Cierra la sesión de Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Verifica si hay una sesión activa de Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}

/// Excepción personalizada para errores de Google Auth
class GoogleAuthException implements Exception {
  final String code;
  final String message;

  GoogleAuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'GoogleAuthException: [$code] $message';
}

// =====================================================
// PROVIDERS
// =====================================================

/// Provider del servicio de Google Auth
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});
