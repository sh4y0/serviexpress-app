import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/image_compressor.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/datasources/reniec_api.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class UserRepository {
  static final instance = UserRepository._();
  UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

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

  Stream<Set<UserModel>> findByCategoryStream(String category) {
    try {
      return _firestore
          .collection('users')
          .where('especialidad', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => UserModel.fromJson(doc.data()))
                .where(
                  (user) =>
                      user.especialidad?.isNotEmpty == true &&
                      user.latitud != null &&
                      user.longitud != null &&
                      user.token?.isNotEmpty == true,
                )
                .toSet();
          });
    } catch (e) {
      return const Stream.empty();
    }
  }

  Future<bool> getUserAvailability() async {
    String? userId = await UserPreferences.getUserId();

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists && doc.data()!.containsKey('isAvailable')) {
      return doc['isAvailable'] as bool;
    } else {
      return false;
    }
  }

  Future<void> toggleUserAvailability(bool value) async {
    String? userId = await UserPreferences.getUserId();

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await docRef.set({'isAvailable': value}, SetOptions(merge: true));
  }

  Future<String> getUserName(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return "";
    }

    final data = doc.data();
    if (data == null) {
      return "";
    }

    final user = UserModel.fromJson(data);

    final username = user.username;

    return username;
  }

  Future<void> addDataMock(List<UserModel> providers) async {
    final WriteBatch batch = _firestore.batch();
    for (final provider in providers) {
      final docRef = _usersCollection.doc(provider.uid);
      batch.set(docRef, provider.toJson());
    }
    await batch.commit();
  }

  Future<void> deleteMockProvidersByCategory(String categoria) async {
    final QuerySnapshot snapshot =
        await _usersCollection
            .where('rol', isEqualTo: 'Proveedor')
            .where('especialidad', isEqualTo: categoria)
            .where(
              FieldPath.documentId,
              isGreaterThanOrEqualTo: '${categoria}_mock_',
            )
            .where(FieldPath.documentId, isLessThan: '${categoria}_mock_\uf8ff')
            .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<UserModel?> getCurrentUser(String? uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserModel.fromJson(data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<ResultState<String>> desactivateCurrentUserAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return const Failure(UnknownError("No hay un usuario autenticado."));
      }

      final uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isActive': false,
      });

      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.authStateChanges().first;

      return const Success("Cuenta desactivada exitosamente.");
    } catch (e) {
      return Failure(ErrorMapper.map(e));
    }
  }

  Future<void> addUserProfilePhoto(Uint8List photoBytes) async {
    final userId = await UserPreferences.getUserId();
    if (userId == null) throw Exception("Usuario no autenticado");

    try {
      final storageRef = _storage
          .ref()
          .child('users/profile_photos')
          .child('$userId.jpg');

      final compressed = await ImageCompressor.compressUint8List(photoBytes);
      final uploadTask = await storageRef.putData(compressed);

      final imageUrl = await uploadTask.ref.getDownloadURL();

      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.update({'imagenUrl': imageUrl});
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> addUserDNIPhoto(Uint8List? front, Uint8List? back) async {
    final userId = await UserPreferences.getUserId();
    if (userId == null) throw Exception("Usuario no autenticado");

    try {
      if (front == null || back == null) {
        throw Exception('Ambas fotos del DNI son requeridas.');
      }

      final frontRef = _storage
          .ref()
          .child('users/dni_photos')
          .child('${userId}_front.jpg');

      final backRef = _storage
          .ref()
          .child('users/dni_photos')
          .child('${userId}_back.jpg');

      final dniCompressedFront = await ImageCompressor.compressUint8List(front);
      final dniCompressedBack = await ImageCompressor.compressUint8List(back);

      final frontUploadTask = await frontRef.putData(dniCompressedFront);
      final backUploadTask = await backRef.putData(dniCompressedBack);

      final frontUrl = await frontUploadTask.ref.getDownloadURL();
      final backUrl = await backUploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'dniFrontImageUrl': frontUrl,
        'dniBackImageUrl': backUrl,
      });
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> addUserCriminalRecord(File? file) async {
    final userId = await UserPreferences.getUserId();
    if (userId == null) throw Exception("Usuario no autenticado");
    try {
      if (file == null) {
        throw Exception('El archivo de antecedentes penales es requerido.');
      }
      final fileExtension = file.path.split('.').last.toLowerCase();
      if (fileExtension != 'pdf' && fileExtension != 'docx') {
        throw Exception('Solo se permiten archivos PDF o DOCX.');
      }
      final fileRef = _storage
          .ref()
          .child('users/criminal_records')
          .child('$userId.$fileExtension');

      final uploadTask = await fileRef.putFile(file);
      final fileUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'criminalRecordUrl': fileUrl,
      });
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> addUserSignature(Uint8List firmaBytes) async {
    final userId = await UserPreferences.getUserId();
    if (userId == null) throw Exception("Usuario no autenticado");
    try {
      final storageRef = _storage
          .ref()
          .child('users/signatures')
          .child('$userId.png');

      final uploadTask = await storageRef.putData(
        firmaBytes,
        SettableMetadata(contentType: 'image/png'),
      );

      final imageUrl = await uploadTask.ref.getDownloadURL();

      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.update({'signatureUrl': imageUrl});
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> updateUserCuentanosById(
    Map<String, dynamic> dataToUpdate,
  ) async {
    final uid = await UserPreferences.getUserId();
    if (uid == null) throw Exception("Usuario no autenticado");
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw const UserNotFound("Usuario no encontrado para editar.");
    }

    if (dataToUpdate.containsKey('dni')) {
      final dni = dataToUpdate['dni'] as String;

      final dniResult = await ReniecApi.instance.searchByDNI(dni);

      if (dniResult is! Success) {
        throw const UnknownError("No se pudo obtener los datos del DNI.");
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
  }
}
