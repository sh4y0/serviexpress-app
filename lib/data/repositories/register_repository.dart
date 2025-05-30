import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class RegisterRepository {
  RegisterRepository._privateConstructor();
  static final RegisterRepository instance =
      RegisterRepository._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ResultState<UserModel>> registerUser(
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

      final String uid = user.uid;

      String rolSaved = await UserPreferences.getRoleName() ?? '';

      final UserModel userModel = UserModel(
        uid: uid,
        username: username,
        email: email,
        telefono: '',
        nombres: '',
        dni: '',
        apellidoPaterno: '',
        apellidoMaterno: '',
        nombreCompleto: '',
        createdAt: DateTime.now(),
        rol: rolSaved,
        especialidad: "",
        descripcion: "",
      );

      await _firestore.collection('users').doc(uid).set(userModel.toJson());
      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return Failure(UnknownError("Error al registrar: ${e.toString()}"));
    }
  }
}
