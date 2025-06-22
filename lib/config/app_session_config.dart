import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/presentation/pages/onboarnding_screen.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';

class AppSessionConfig {
  static Future<void> handleAuthRedirect(
    BuildContext context,
    RemoteMessage? initialMessage,
  ) async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    await MapStyleLoader.loadStyle();

    if (user == null) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const OnboarndingScreen()),
      );
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = doc.data();

      if (data == null) {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const OnboarndingScreen()),
          );
        }
        return;
      }

      final role = data['rol'];

      final serviceId = initialMessage?.data['idServicio'];
      if (serviceId != null) {
        final service = await ServiceRepository.instance.getService(serviceId);
        if (service != null && context.mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.providerDetails,
            arguments: {
              'service': service,
              'mapStyle': MapStyleLoader.cachedStyle,
            },
          );
          return;
        }
      }

      if (role == "Trabajador") {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.homeProvider);
        }
      } else if (role == "Cliente") {
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
            arguments: MapStyleLoader.cachedStyle,
          );
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const OnboarndingScreen()),
          );
        }
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const OnboarndingScreen()),
        );
      }
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;
}
