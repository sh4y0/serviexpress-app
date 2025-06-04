import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/messaging/service/firebase_messaging_service.dart';
import 'package:uuid/uuid.dart';

class ServiceRepository {
  ServiceRepository._privateConstructor();
  static final ServiceRepository instance =
      ServiceRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ResultState<ServiceModel>> createService(ServiceModel service) async {
    try {
      final String serviceId = service.id;
      List<String> fotoUrls = [];
      List<String> videoUrls = [];

      if (service.fotosFiles != null) {
        for (int i = 0; i < service.fotosFiles!.length; i++) {
          final String fileName =
              '${serviceId}_foto_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/$fileName');
          final uploadTask = await ref.putFile(service.fotosFiles![i]);
          final url = await uploadTask.ref.getDownloadURL();
          fotoUrls.add(url);
        }
      }

      if (service.videosFiles != null) {
        for (int i = 0; i < service.videosFiles!.length; i++) {
          final String fileName =
              '${serviceId}_video_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/$fileName');
          final uploadTask = await ref.putFile(service.videosFiles![i]);
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

      final message = FCMMessage(
        token: '',
        idServicio: serviceId,
        senderId: updatedService.clientId,
        title: 'Tienes un nuevo servicio',
        body: 'Limpieza solicitada por ${updatedService.clientId}',
        receiverId: updatedService.workerId,
      );

      await _firestore
          .collection('services')
          .doc(serviceId)
          .set(updatedService.toJson());

      await FirebaseMessagingService.instance.sendFCMMessage(
        message,
        updatedService.workerId,
      );

      return Success(updatedService);
    } catch (e) {
      return Failure(
        UnknownError("Error al crear el servicio: ${e.toString()}"),
      );
    }
  }

  Future<ServiceComplete?> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();

      if (!doc.exists) {
        //return const Failure(UnknownError("Servicio no encontrado."));
        return null;
      }

      final serviceModel = ServiceModel.fromJson(doc.data()!);

      final clienteDoc =
          await _firestore.collection('users').doc(serviceModel.clientId).get();
      if (!clienteDoc.exists) {
        /*return Failure(
          UnknownError('El cliente con ID ${serviceModel.clientId} no existe'),
        );*/
        return null;
      }

      final trabajadorDoc =
          await _firestore.collection('users').doc(serviceModel.workerId).get();
      if (!trabajadorDoc.exists) {
        /*return Failure(
          UnknownError(
            'El trabajador con ID ${serviceModel.workerId} no existe',
          ),
        );*/
        return null;
      }

      final cliente = UserModel.fromJson(
        clienteDoc.data()!..['id'] = clienteDoc.id,
      );
      final trabajador = UserModel.fromJson(
        trabajadorDoc.data()!..['id'] = trabajadorDoc.id,
      );

      final service = ServiceComplete(
        service: serviceModel,
        cliente: cliente,
        trabajador: trabajador,
      );

      return service;
    } catch (e) {
      /*return Failure(
        UnknownError("Error al obtener el servicio: ${e.toString()}"),
      );*/
      print('Error al obtener el servicio: ${e.toString()}');
    }
    return null;
  }

  String generateServiceId() {
    return const Uuid().v4();
  }
}
