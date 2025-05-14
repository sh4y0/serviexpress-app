import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/error_state.dart';
import 'package:serviexpress_app/core/utils/error_mapper.dart';

class AuthRepository {
  AuthRepository._privateConstructor();
  static final AuthRepository instance = AuthRepository._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ResultState<User>> loginUser(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
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
