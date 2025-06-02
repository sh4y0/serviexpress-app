import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class ServiceRepository {
  ServiceRepository._privateConstructor();
  static final ServiceRepository instance =
      ServiceRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ResultState<ServiceModel>> createService({
    required ServiceModel service,
    List<File>? fotos,
    List<File>? videos,
  }) async {
    try {
      final String serviceId = service.id;
      List<String> fotoUrls = [];
      List<String> videoUrls = [];

      if (fotos != null) {
        for (int i = 0; i < fotos.length; i++) {
          final String fileName =
              '${serviceId}_foto_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/$fileName');
          final uploadTask = await ref.putFile(fotos[i]);
          final url = await uploadTask.ref.getDownloadURL();
          fotoUrls.add(url);
        }
      }

      if (videos != null) {
        for (int i = 0; i < videos.length; i++) {
          final String fileName =
              '${serviceId}_video_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/$fileName');
          final uploadTask = await ref.putFile(videos[i]);
          final url = await uploadTask.ref.getDownloadURL();
          videoUrls.add(url);
        }
      }

      final updatedService = ServiceModel(
        id: service.id,
        categoria: service.categoria,
        descripcion: service.descripcion,
        estado: service.estado,
        clientId: service.clientId,
        workerId: service.workerId,
        fotos: fotoUrls,
        videos: videoUrls,
        fechaCreacion: service.fechaCreacion ?? DateTime.now(),
        fechaFinalizacion: service.fechaFinalizacion,
      );

      await _firestore
          .collection('services')
          .doc(serviceId)
          .set(updatedService.toJson());

      return Success(updatedService);
    } catch (e) {
      return Failure(
        UnknownError("Error al crear el servicio: ${e.toString()}"),
      );
    }
  }

  Future<ResultState<Service>> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();

      if (!doc.exists) {
        return const Failure(UnknownError("Servicio no encontrado."));
      }

      final serviceModel = ServiceModel.fromJson(doc.data()!);

      final clienteDoc =
          await _firestore.collection('users').doc(serviceModel.clientId).get();
      if (!clienteDoc.exists) {
        return Failure(
          UnknownError('El cliente con ID ${serviceModel.clientId} no existe'),
        );
      }

      final trabajadorDoc =
          await _firestore.collection('users').doc(serviceModel.workerId).get();
      if (!trabajadorDoc.exists) {
        return Failure(
          UnknownError(
            'El trabajador con ID ${serviceModel.workerId} no existe',
          ),
        );
      }

      final cliente = UserModel.fromJson(
        clienteDoc.data()!..['id'] = clienteDoc.id,
      );
      final trabajador = UserModel.fromJson(
        trabajadorDoc.data()!..['id'] = trabajadorDoc.id,
      );

      final service = Service(
        service: serviceModel,
        cliente: cliente,
        trabajador: trabajador,
      );

      return Success(service);
    } catch (e) {
      return Failure(
        UnknownError("Error al obtener el servicio: ${e.toString()}"),
      );
    }
  }

  String generateServiceId() {
    return const Uuid().v4();
  }
}
