import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserRepository.instance.updateUserToken(
          currentUser.uid,
          fcmToken,
        );
        print('[NotificationManager] Token guardado en Firestore');
      }
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('[NotificationManager] Token refrescado: $newToken');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserRepository.instance.updateUserToken(
          currentUser.uid,
          newToken,
        );
        print('[NotificationManager] Token actualizado en Firestore');
      }
    });

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🔔 Abierto desde background: ${message.data}");
    });

    print('[NotificationManager] Inicializado correctamente');
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificaciones Generales',
      channelDescription: 'Canal de notificaciones para mensajes generales',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'] ?? 'Notificación';
    final body =
        notification?.body ?? data['body'] ?? 'Tienes un nuevo mensaje.';

    showLocalNotification(title: title, body: body);
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();

    final data = message.data;
    final title =
        message.notification?.title ?? data['title'] ?? 'Notificación';
    final body =
        message.notification?.body ??
        data['body'] ??
        'Tienes un nuevo mensaje.';

    await NotificationManager().showLocalNotification(title: title, body: body);
    print("📨 [Background] Mensaje recibido: ${message.messageId}");
  }
}
