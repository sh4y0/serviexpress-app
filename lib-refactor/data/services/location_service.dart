import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:serviexpress_app/core/utils/user_preferences.dart';

import 'remote_config_service.dart';

class LocationService {
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placeMarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placeMarks.isNotEmpty){
        final place = placeMarks.first;
        final street = place.street ?? '';
        final locality = place.locality ?? '';
        final address = '$street, $locality';
        
        return address.isNotEmpty ? address : 'Dirección no disponible';
      }
      else{
        return 'Dirección no disponible';
      }
    }
    catch(e){
      return 'Error obteniendo dirección';
    }
  }

  static Future<String> getDistanceFromCurrentLocation(
    double destLat,
    double destLng,
  ) async {
    try {
      final currentUserId = await UserPreferences.getUserId();

      if (currentUserId == null){
        return 'Usuario no encontrado';
      }

      final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

      if (!userDoc.exists || userDoc.data() == null){
        return 'Usuario no encontrado (documento no existe)';
      }

      final userData = userDoc.data()!;
      final currentLat = userData['latitud'];
      final currentLng = userData['longitud'];

      if (currentLat == null || currentLng == null) {
        return "Ubicación actual no disponible";
      }

      final apiKey = RemoteConfigService.instance.getGoogleMapsKey();
      if (apiKey.isEmpty) {
        return "API Key no configurada";
      }

      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/distancematrix/json"
        "?origins=$currentLat,$currentLng"
        "&destinations=$destLat,$destLng"
        "&mode=driving"
        "&language=es"
        "&key=$apiKey",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        return "Error HTTP: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final element = data['rows'][0]['elements'][0];

        if (element['status'] == 'OK') {
          final duration = element['duration']['text'];
          final distance = element['distance']['text'];
          return "$duration ($distance)";
        } else {
          return "Error en elemento: ${element['status']}";
        }
      } else {
        return "Error en status general: ${data['status']}";
      }
    }
    catch(e) {
      return '';
    }
  }
}