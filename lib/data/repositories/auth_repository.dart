import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/auth/auth_provider_strategy.dart';
import 'package:serviexpress_app/data/models/auth/auth_result.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class AuthRepository {
  AuthRepository._privateConstructor();
  static final AuthRepository instance = AuthRepository._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, AuthProviderStrategy> _providers = {
    'google': GoogleAuthProviderStrategy(),
    'facebook': FacebookAuthProviderStrategy(),
    'apple': AppleAuthProviderStrategy(),
  };

  Future<ResultState<AuthResult>> loginUser(
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
        return await _processAuthenticatedUser(user, isNewUser: false);
      } else {
        return const Failure(UnknownError("No se pudo obtener el usuario."));
      }
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (_) {
      return const Failure(UnknownError("Ocurrió un error inesperado."));
    }
  }

  Future<ResultState<AuthResult>> loginWithProvider(String providerName) async {
    final provider = _providers[providerName.toLowerCase()];
    if (provider == null) {
      return Failure(UnknownError("Proveedor '$providerName' no soportado."));
    }

    final authResult = await provider.authenticate();

    if (authResult is Success<User>) {
      return await _processAuthenticatedUser(
        authResult.data,
        isNewUser: false,
        providerName: providerName,
      );
    } else {
      return Failure((authResult as Failure).error);
    }
  }

  Future<ResultState<AuthResult>> registerUser(
    String email,
    String password,
    String username,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) {
        return const Failure(UnknownError("No se pudo crear el usuario."));
      }

      return await _processAuthenticatedUser(
        user,
        isNewUser: true,
        username: username,
      );
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return Failure(UnknownError("Error al registrar: ${e.toString()}"));
    }
  }

  Future<ResultState<AuthResult>> _processAuthenticatedUser(
    User firebaseUser, {
    required bool isNewUser,
    String? providerName,
    String? username,
  }) async {
    try {
      final DocumentReference docRef = _firestore
          .collection('users')
          .doc(firebaseUser.uid);

      final DocumentSnapshot doc = await docRef.get();
      UserModel userModel;
      bool needsProfileCompletion = false;

      if (!doc.exists || isNewUser) {
        final String rolSaved = await UserPreferences.getRoleName() ?? '';

        userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: username ?? _buildUsername(firebaseUser.displayName),
          dni: '',
          telefono: '',
          nombres: firebaseUser.displayName ?? '',
          apellidoPaterno: '',
          apellidoMaterno: '',
          nombreCompleto: firebaseUser.displayName ?? '',
          createdAt: DateTime.now(),
          rol: rolSaved,
          especialidad: "",
          descripcion: "",
        );

        await docRef.set(userModel.toJson());
        needsProfileCompletion = await _checkProfileCompletion(userModel);
      } else {
        final data = doc.data() as Map<String, dynamic>;
        userModel = UserModel.fromJson(data);
        needsProfileCompletion = await _checkProfileCompletion(userModel);
      }

      return Success(
        AuthResult(
          userModel: userModel,
          isNewUser: isNewUser,
          needsProfileCompletion: needsProfileCompletion,
        ),
      );
    } catch (e) {
      return Failure(UnknownError("Error procesando usuario: ${e.toString()}"));
    }
  }

  Future<bool> _checkProfileCompletion(UserModel user) async {
    if (user.rol == "Trabajador") {
      return user.dni.trim().isEmpty;
    }
    return false;
  }

  Future<ResultState<String>> recoverPassword(String email) async {
    try {
      final snapshot =
          await _firestore
              .collection("users")
              .where("email", isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return const Failure(
          UserNotFound("El correo electrónico no está registrado."),
        );
      }

      await _auth.sendPasswordResetEmail(email: email);
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

  void addAuthProvider(String name, AuthProviderStrategy provider) {
    _providers[name.toLowerCase()] = provider;
  }

  List<String> getAvailableProviders() {
    return _providers.keys.toList();
  }

  String _buildUsername(String? displayName) {
    if (displayName == null || displayName.isEmpty) return '';
    return displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }
}
