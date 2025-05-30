import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProveedorModel {
  final String id;
  final String nombre;
  final String categoria;
  final LatLng? ubicacion;
  final double calificacion;
  final List? resenias;
  final String? descripcion;
  final String imagenUrl;

  ProveedorModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.ubicacion,
    required this.calificacion,
    this.resenias,
    this.descripcion,
    required this.imagenUrl,
  });
}
