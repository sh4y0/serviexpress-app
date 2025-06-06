import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/datasources/reniec_api.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class UserRepository {
  static final instance = UserRepository._();
  UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isDniEmpty(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) throw Exception("Usuario no encontrado en Firestore.");

    final data = doc.data();
    final dni = data?['dni'] as String?;
    final rol = data?['rol'] as String?;

    if (rol == "Trabajador") {
      return dni == null || dni.trim().isEmpty;
    }
    return false;
  }

  Future<ResultState<UserModel>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return const Failure(
          UserNotFound("Usuario no encontrado en Firestore."),
        );
      }

      final data = doc.data();
      if (data == null) {
        return const Failure(UnknownError("Los datos del usuario son nulos."));
      }

      final user = UserModel.fromJson(data);
      return Success(user);
    } catch (e) {
      return Failure(ErrorMapper.map(e));
    }
  }

  Future<ResultState<String>> updateUserById(
    String uid,
    Map<String, dynamic> dataToUpdate,
  ) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        return const Failure(
          UserNotFound("Usuario no encontrado para editar."),
        );
      }

      if (dataToUpdate.containsKey('dni')) {
        final dni = dataToUpdate['dni'] as String;

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

        dataToUpdate['nombres'] = nombres;
        dataToUpdate['apellidoPaterno'] = apellidoPaterno;
        dataToUpdate['apellidoMaterno'] = apellidoMaterno;
        dataToUpdate['nombreCompleto'] = nombreCompleto;
      }

      await docRef.update(dataToUpdate);
      return const Success("Usuario actualizado correctamente.");
    } catch (e) {
      return Failure(ErrorMapper.map(e));
    }
  }

  Future<void> updateUserToken(String uid, String token) async {
    final userDoc = _firestore.collection('users').doc(uid);

    await userDoc.update({'token': token});
  }

  Future<void> setUserLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    final userDoc = _firestore.collection('users').doc(uid);

    await userDoc.update({'latitud': latitude, 'longitud': longitude});
  }

  Future<List<UserModel>> findByCategory(String category) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('especialidad', isEqualTo: category)
              .get();

      final users =
          querySnapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList();
      return users;
    } catch (e) {
      return [];
    }
  }
}
