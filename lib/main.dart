import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/data/service/remote_config_service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/pages/serviexpress.dart';
import 'firebase_options.dart';

void main() async {
  Logger.root.level = Level.ALL;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(
    NotificationManager.handleBackgroundMessage,
  );
  await RemoteConfigService.instance.initialize();
  runApp(const ProviderScope(child: Serviexpress()));
}
