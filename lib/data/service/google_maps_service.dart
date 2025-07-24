import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:serviexpress_app/data/service/remote_config_service.dart';

class GoogleMapsService {
  final String _apiKey = RemoteConfigService.instance.getGoogleMapsKey();

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if ((jsonResponse['routes'] as List).isNotEmpty) {
          final String encodedPolyline =
              jsonResponse['routes'][0]['overview_polyline']['points'];

          final List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
            encodedPolyline,
          );
          return decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        } else {
          debugPrint('No se encontraron rutas: ${jsonResponse['status']}');
          return [];
        }
      } else {
        debugPrint('Error en la API de Direcciones: ${response.statusCode}');
        debugPrint('Respuesta: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción al obtener direcciones: $e');
      return [];
    }
  }
}
