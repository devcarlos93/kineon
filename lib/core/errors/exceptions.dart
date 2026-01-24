/// Excepción base de la aplicación
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Excepción de servidor
class ServerException extends AppException {
  const ServerException({
    super.message = 'Error del servidor',
    super.code,
  });
}

/// Excepción de red
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Error de conexión',
    super.code,
  });
}

/// Excepción de autenticación
class AuthException extends AppException {
  const AuthException({
    super.message = 'Error de autenticación',
    super.code,
  });
}

/// Excepción de caché
class CacheException extends AppException {
  const CacheException({
    super.message = 'Error de caché',
    super.code,
  });
}

/// Excepción de no encontrado
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Recurso no encontrado',
    super.code,
  });
}
