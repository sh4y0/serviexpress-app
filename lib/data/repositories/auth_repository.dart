import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class AuthRepository {
  AuthRepository._privateConstructor();
  static final AuthRepository instance = AuthRepository._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            await _firestore
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

  Future<ResultState<User>> loginWithGoogle() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return const Failure(UserNotFound("Inicio de sesión cancelado."));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user == null) {
        return const Failure(UnknownError("No se pudo autenticar con Google."));
      }

      final DocumentReference docRef = _firestore
          .collection('users')
          .doc(user.uid);

      String rolSaved = await UserPreferences.getRoleName() ?? '';

      final DocumentSnapshot doc = await docRef.get();
      if (!doc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: _buildUsername(user.displayName),
          dni: '',
          telefono: '',
          nombres: user.displayName ?? '',
          apellidoPaterno: '',
          apellidoMaterno: '',
          nombreCompleto: user.displayName ?? '',
          createdAt: DateTime.now(),
          rol: rolSaved,
          especialidad: "",
          descripcion: "",
        );

        await docRef.set(newUser.toJson());
        return Success(user);
      }

      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return const Failure(
        UnknownError("Error inesperado en login con Google."),
      );
    }
  }

  Future<ResultState<User>> loginWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();

      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        return const Failure(
          UserNotFound("Inicio de sesión cancelado o fallido."),
        );
      }

      final accessToken = loginResult.accessToken;
      if (accessToken == null) {
        return const Failure(UserNotFound("No se obtuvo token de Facebook."));
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      final UserCredential userCredential = await _auth.signInWithCredential(
        facebookAuthCredential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        return const Failure(
          UnknownError("No se pudo autenticar con Facebook."),
        );
      }

      final DocumentReference docRef = _firestore
          .collection('users')
          .doc(user.uid);
      String rolSaved = await UserPreferences.getRoleName() ?? '';

      final DocumentSnapshot doc = await docRef.get();
      if (!doc.exists) {
        final userData = await FacebookAuth.instance.getUserData();

        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: _buildUsername(userData['name']),
          dni: '',
          telefono: '',
          nombres: userData['name'] ?? '',
          apellidoPaterno: '',
          apellidoMaterno: '',
          nombreCompleto: userData['name'] ?? '',
          createdAt: DateTime.now(),
          rol: rolSaved,
          especialidad: "",
          descripcion: "",
        );

        await docRef.set(newUser.toJson());
        return Success(user);
      }

      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return const Failure(
        UnknownError("Error inesperado en login con Facebook."),
      );
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

  String _buildUsername(String? displayName) {
    if (displayName == null || displayName.isEmpty) return '';
    return displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }
}
