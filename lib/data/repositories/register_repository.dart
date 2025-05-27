import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/datasources/reniec_api.dart';
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
    String dni,
    String username,
  ) async {
    try {
      final bool dniExists = await _isDniAlreadyRegistered(dni);
      if (dniExists) {
        return const Failure(UnknownError("El DNI ya está registrado."));
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user == null) {
        return const Failure(UnknownError("No se pudo crear el usuario."));
      }

      final String uid = user.uid;

      final dniResult = await ReniecApi.instance.searchByDNI(dni);

      if (dniResult is! Success) {
        return const Failure(
          UnknownError("No se pudo obtener los datos del DNI."),
        );
      }

      final Map<String, dynamic> dniData = (dniResult as Success).data;
      final String nombres = dniData['nombres'] ?? '';
      final String apellidoPaterno = dniData['apellidoPaterno'] ?? '';
      final String apellidoMaterno = dniData['apellidoMaterno'] ?? '';
      final String nombreCompleto =
          "$nombres $apellidoPaterno $apellidoMaterno";

      String rolSaved = await UserPreferences.getRoleName() ?? '';

      final UserModel userModel = UserModel(
        uid: uid,
        username: username,
        email: email,
        dni: dni,
        telefono: '',
        nombres: nombres,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
        nombreCompleto: nombreCompleto,
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

  Future<bool> _isDniAlreadyRegistered(String dni) async {
    final query =
        await _firestore
            .collection('users')
            .where('dni', isEqualTo: dni)
            .limit(1)
            .get();

    return query.docs.isNotEmpty;
  }
}
