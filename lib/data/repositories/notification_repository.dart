import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';

class NotificationRepository {
  NotificationRepository._privateConstructor();
  static final NotificationRepository instance =
      NotificationRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'notifications';

  Future<void> saveNotification(FCMMessage message) async {
    try {
      await _firestore
          .collection(collectionName)
          .add(message.toFirestoreJson());
    } catch (e) {
      throw Exception('Error guardando notificación: $e');
    }
  }
}
