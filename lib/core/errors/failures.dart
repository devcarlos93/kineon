import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de servidor (API, Supabase)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor. Inténtalo de nuevo más tarde.',
    super.code,
  });
}

/// Fallo de conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet. Verifica tu conexión.',
    super.code,
  });
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Error de autenticación.',
    super.code,
  });
}

/// Usuario no autenticado
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure({
    super.message = 'Debes iniciar sesión para continuar.',
    super.code,
  });
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder a los datos locales.',
    super.code,
  });
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado.',
    super.code,
  });
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'No tienes permisos para realizar esta acción.',
    super.code,
  });
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ha ocurrido un error inesperado.',
    super.code,
  });
}
