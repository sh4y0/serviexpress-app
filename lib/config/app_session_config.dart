import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/onboarding/onboarnding_screen.dart';
import 'package:serviexpress_app/presentation/widgets/common/map_style_loader.dart';
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
        final userId = await UserPreferences.getUserId();
        LatLng? position;
        if (userId != null) {
          final worker = await UserRepository.instance.getCurrentUser(userId);
          if (worker != null) {
            position = LatLng(worker.latitud ?? 0.0, worker.longitud ?? 0.0);
          }
        }
        if (service != null && context.mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.providerDetails,
            arguments: {
              'service': service,
              'mapStyle': MapStyleLoader.cachedStyle,
              'position': position,
            },
          );
          return;
        }
      }

      if (role == "Trabajador" && data['isCompleteProfile']) {
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
