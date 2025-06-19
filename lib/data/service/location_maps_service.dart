import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class LocationMapsService {
  final Logger _log = Logger('LocationMapsService');
  static final LocationMapsService _instance = LocationMapsService._internal();
  factory LocationMapsService() => _instance;
  LocationMapsService._internal();

  LocationSettings _getLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Obteniendo ubicación...",
          notificationTitle: "Ubicación en uso",
          enableWakeLock: true,
        ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(
          locationSettings: _getLocationSettings(),
        );
  }

  Future<void> initialize() async {
    await Geolocator.isLocationServiceEnabled();

    try {
      final userId = await UserPreferences.getUserId();
      if (userId == null) return;

      final position = await getCurrentPosition();

      final latitud = position.latitude;
      final longitud = position.longitude;

      await UserRepository.instance.setUserLocation(userId, latitud, longitud);
    } catch (e) {
      _log.severe("Error al inicializar el servicio de ubicación: $e");
    }
  }
}
