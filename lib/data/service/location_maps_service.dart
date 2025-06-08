import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class LocationMapsService {
  final Logger _log = Logger('LocationMapsService');
  static final LocationMapsService _instance = LocationMapsService._internal();
  factory LocationMapsService() => _instance;
  LocationMapsService._internal();

  Future<void> initialize() async {
    await Geolocator.isLocationServiceEnabled();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final position =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

      final latitud = position.latitude;
      final longitud = position.longitude;

      await UserRepository.instance.setUserLocation(
        user.uid,
        latitud,
        longitud,
      );
    } catch (e) {
      _log.severe("Error al inicializar el servicio de ubicación: $e");
    }
  }
}
