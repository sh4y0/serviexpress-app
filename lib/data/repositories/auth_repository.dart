import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';

class AuthRepository {
  AuthRepository._privateConstructor();
  static final AuthRepository instance = AuthRepository._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ResultState<User>> loginUser(
    String identifier,
    String password,
  ) async {
    try {
      String email;

      if (identifier.contains('@')) {
        email = identifier;
      } else {
        final snap =
            await FirebaseFirestore.instance
                .collection("users")
                .where("username", isEqualTo: identifier)
                .limit(1)
                .get();

        if (snap.docs.isEmpty) {
          return const Failure(UserNotFound("Nombre de usuario incorrecto."));
        }

        email = snap.docs.first['email'];
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        return Success(user);
      } else {
        return const Failure(UnknownError("No se pudo obtener el usuario."));
      }
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (_) {
      return const Failure(UnknownError("Ocurrió un error inesperado."));
    }
  }

  Future<ResultState<String>> recoverPassword(String email) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where("email", isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return const Failure(
          UserNotFound("El correo electrónico no está registrado."),
        );
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return Success('Correo de recuperación enviado a $email');
    } catch (e) {
      return Failure(ErrorMapper.map(e));
    }
  }

  ResultState<String> logout() {
    try {
      _auth.signOut();
      return const Success("Cierre de sesión exitoso");
    } catch (_) {
      return const Failure(UnknownError("Error al cerrar sesión"));
    }
  }
}
