import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/presentation/messaging/service/firebase_messaging_service.dart';
import 'package:uuid/uuid.dart';

class ServiceRepository {
  final Logger _log = Logger('ServiceRepository');
  ServiceRepository._privateConstructor();
  static final ServiceRepository instance =
      ServiceRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ResultState<ServiceModel>> createService(
    List<String> workersId,
    ServiceModel service,
  ) async {
    try {
      final String serviceId = service.id;
      List<String> fotoUrls = [];
      List<String> videoUrls = [];
      List<String> audioUrls = [];

      if (service.fotosFiles != null) {
        for (int i = 0; i < service.fotosFiles!.length; i++) {
          final String fileName =
              '${serviceId}_photo_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/photos/$fileName');
          final uploadTask = await ref.putFile(service.fotosFiles![i]);
          final url = await uploadTask.ref.getDownloadURL();
          fotoUrls.add(url);
        }
      }

      if (service.videosFiles != null) {
        for (int i = 0; i < service.videosFiles!.length; i++) {
          final String fileName =
              '${serviceId}_video_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/videos/$fileName');
          final uploadTask = await ref.putFile(service.videosFiles![i]);
          final url = await uploadTask.ref.getDownloadURL();
          videoUrls.add(url);
        }
      }

      if (service.audioFiles != null) {
        for (int i = 0; i < service.audioFiles!.length; i++) {
          final String fileName =
              '${serviceId}_audio_${(i + 1).toString().padLeft(3, '0')}';
          final ref = _storage.ref().child('services/audios/$fileName');
          final uploadTask = await ref.putFile(service.audioFiles![i]);
          final url = await uploadTask.ref.getDownloadURL();
          audioUrls.add(url);
        }
      }

      final updatedService = ServiceModel(
        id: serviceId,
        categoria: service.categoria,
        descripcion: service.descripcion,
        estado: service.estado,
        clientId: service.clientId,
        workerId: service.workerId,
        fotos: fotoUrls,
        videos: videoUrls,
        audios: audioUrls,
        fechaCreacion: service.fechaCreacion ?? DateTime.now(),
        fechaFinalizacion: service.fechaFinalizacion,
        workersId: workersId,
      );

      await _firestore
          .collection('services')
          .doc(serviceId)
          .set(updatedService.toJson());
      _log.info('Servicio creado con ID: $serviceId');

      final username = await UserRepository.instance.getUserName(
        service.clientId,
      );

      for (final workerId in workersId) {
        final message = FCMMessage(
          token: '',
          idServicio: serviceId,
          senderId: updatedService.clientId,
          title: 'Tienes un nuevo servicio',
          body: 'Limpieza solicitada por $username',
          receiverId: workerId,
        );

        await FirebaseMessagingService.instance.sendFCMMessage(
          message,
          workerId,
        );

        _log.info('Notificación enviada');
      }

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
        _log.warning('Servicio no encontrado: $serviceId');
        return null;
      }

      final serviceModel = ServiceModel.fromJson(doc.data()!);

      final clienteDoc =
          await _firestore.collection('users').doc(serviceModel.clientId).get();
      if (!clienteDoc.exists) {
        return null;
      }

      final cliente = UserModel.fromJson(
        clienteDoc.data()!..['id'] = clienteDoc.id,
      );

      final service = ServiceComplete(service: serviceModel, cliente: cliente);

      return service;
    } catch (e) {
      _log.severe('Error al obtener el servicio: ${e.toString()}');
    }
    return null;
  }

  String generateServiceId() {
    return const Uuid().v4();
  }
}
