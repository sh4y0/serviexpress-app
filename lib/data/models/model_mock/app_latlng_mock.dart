import 'package:flutter/foundation.dart';

@immutable
class AppLatLngMock {
  final double latitude;
  final double longitude;

  const AppLatLngMock(this.latitude, this.longitude);

  @override
  String toString() {
    return 'Lat: $latitude, Lng: $longitude';
  }

  static Map<String, List<AppLatLngMock>> trujilloRandomPoints = {
    'Limpieza': const [
      // Trujillo
      AppLatLngMock(-8.1064, -79.0435),
      AppLatLngMock(-8.1287, -79.0384),
      AppLatLngMock(-8.1181, -79.0118),
      AppLatLngMock(-8.0945, -79.0264),
      AppLatLngMock(-8.1213, -79.0481),
      AppLatLngMock(-8.1251, -79.0152),
      AppLatLngMock(-8.0921, -79.0337),

      // La Esperanza
      AppLatLngMock(-8.0645, -79.0628),
      AppLatLngMock(-8.0931, -79.0573),
      AppLatLngMock(-8.0863, -79.0301),
      AppLatLngMock(-8.0601, -79.0431),
      AppLatLngMock(-8.0827, -79.0674),
      AppLatLngMock(-8.07135, -79.05491),
      AppLatLngMock(-8.07681, -79.05923),
      AppLatLngMock(-8.07542, -79.05315),
      AppLatLngMock(-8.06998, -79.05876),
      AppLatLngMock(-8.07894, -79.05652),
      AppLatLngMock(-8.07311, -79.06188),
      AppLatLngMock(-8.07025, -79.05564),

      // Huanchaco
      // AppLatLngMock(-8.0871, -79.1026),
      // AppLatLngMock(-8.0623, -79.1105),
      // AppLatLngMock(-8.0924, -79.1332),

      // Moche
      // AppLatLngMock(-8.1764, -79.0142),
      // AppLatLngMock(-8.1481, -78.9926),
      // AppLatLngMock(-8.1408, -79.0119),

      // Florencia de Mora
      AppLatLngMock(-8.0825, -79.0163),
      AppLatLngMock(-8.1051, -79.0274),
      AppLatLngMock(-8.0716, -79.0388),
      AppLatLngMock(-8.0989, -79.0491),

      // Salaverry
      // AppLatLngMock(-8.2065, -78.9701),
      // AppLatLngMock(-8.2393, -78.9876),
    ],

    'Reparador': const [
      // La Esperanza
      AppLatLngMock(-8.07195, -79.05601),
      AppLatLngMock(-8.07512, -79.05815),
      AppLatLngMock(-8.07446, -79.05533),
      AppLatLngMock(-8.07268, -79.05892),
      AppLatLngMock(-8.07593, -79.05674),
    ],
  };
}

const Map<String, AppLatLngMock> trujilloDistrictCoords = {
  'Trujillo': AppLatLngMock(-8.1116, -79.0285),
  'La Esperanza': AppLatLngMock(-8.0773, -79.0492),
  'Huanchaco': AppLatLngMock(-8.0775, -79.1208),
  'Moche': AppLatLngMock(-8.1595, -79.0063),
  'Florencia de Mora': AppLatLngMock(-8.0892, -79.0345),
  'Salaverry': AppLatLngMock(-8.2231, -78.9775),
};
