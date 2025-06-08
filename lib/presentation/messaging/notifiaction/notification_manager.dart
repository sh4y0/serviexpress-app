import 'dart:async';
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

  final StreamController<RemoteMessage> _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

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
      }
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserRepository.instance.updateUserToken(
          currentUser.uid,
          newToken,
        );
      }
    });

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Aquí puedes manejar acciones al tocar la notificación
      },
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Aquí puedes manejar navegación o acciones específicas
    });
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
      icon: '@mipmap/ic_notification',
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

    _notificationStreamController.add(message);

    if (notification == null) {
      showLocalNotification(title: title, body: body);
    }
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
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
