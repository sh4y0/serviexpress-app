import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';

class ErrorMapper {
  static ErrorState map(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapAuthError(error);
    } else if (error is FirebaseException &&
        error.plugin == 'cloud_firestore') {
      return _mapFirestoreError(error);
    } else if (error is FirebaseException &&
        error.plugin == 'firebase_storage') {
      return _mapStorageError(error);
    } else {
      return const UnknownError("Ha ocurrido un error inesperado.");
    }
  }

  static ErrorState _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
        return const InvalidCredentials(
          "Las credenciales que ingresó son incorrectas",
        );
      case 'invalid-email':
        return const InvalidCredentials("Correo inválido.");
      case 'email-already-in-use':
        return const EmailAlreadyInUse("Este correo ya está registrado.");
      case 'user-not-found':
        return const UserNotFound("No se encontró una cuenta con este correo.");
      case 'wrong-password':
        return const InvalidCredentials("Contraseña incorrecta.");
      case 'weak-password':
        return const CustomError("La contraseña es muy débil.");
      case 'user-disabled':
        return const CustomError("Esta cuenta ha sido deshabilitada.");
      case 'too-many-requests':
        return const TooManyRequest("Demasiados intentos. Intenta más tarde.");
      case 'network-request-failed':
        return const NetworkError("Verifica tu conexión a internet.");
      case 'operation-not-allowed':
        return const CustomError("Operación no permitida.");
      case 'user-token-expired':
        return const CustomError("Sesión expirada.");
      case 'invalid-user-token':
        return const CustomError("Token inválido.");
      default:
        return const UnknownError("Error inesperado de autenticación.");
    }
  }

  static ErrorState _mapFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'cancelled':
        return const CustomError("La operación fue cancelada.");
      case 'unknown':
        return const UnknownError("Error desconocido en Firestore.");
      case 'invalid-argument':
        return const CustomError("Argumento inválido.");
      case 'deadline-exceeded':
        return const CustomError("Tiempo de espera excedido.");
      case 'not-found':
        return const CustomError("Documento no encontrado.");
      case 'already-exists':
        return const CustomError("Ya existe un documento igual.");
      case 'permission-denied':
        return const CustomError("Permiso denegado.");
      case 'resource-exhausted':
        return const CustomError("Recursos agotados.");
      case 'failed-precondition':
        return const CustomError("Condición fallida.");
      case 'aborted':
        return const CustomError("Operación abortada.");
      case 'unimplemented':
        return const CustomError("Función no implementada.");
      case 'internal':
        return const CustomError("Error interno.");
      case 'unavailable':
        return const ServiceUnavailable("Servicio no disponible.");
      case 'data-loss':
        return const CustomError("Pérdida de datos.");
      case 'unauthenticated':
        return const InvalidCredentials("No has iniciado sesión.");
      default:
        return const UnknownError("Error desconocido en Firestore.");
    }
  }

  static ErrorState _mapStorageError(FirebaseException error) {
    switch (error.code) {
      case 'object-not-found':
        return const CustomError("Archivo no encontrado.");
      case 'unauthorized':
        return const Unauthorized("Sin permisos.");
      case 'cancelled':
        return const CustomError("Operación cancelada.");
      case 'unknown':
        return const UnknownError("Error en Storage.");
      case 'bucket-not-found':
        return const CustomError("Bucket no encontrado.");
      case 'project-not-found':
        return const CustomError("Proyecto no encontrado.");
      case 'quota-exceeded':
        return const CustomError("Límite de almacenamiento superado.");
      case 'retry-limit-exceeded':
        return const CustomError("Demasiados intentos.");
      case 'non-matching-checksum':
        return const CustomError("Archivo dañado.");
      case 'invalid-argument':
        return const CustomError("Argumento inválido.");
      default:
        return const UnknownError("Error desconocido en Storage.");
    }
  }
}
