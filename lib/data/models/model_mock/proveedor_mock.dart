import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/data/models/proveedor_model.dart';

class ProveedorMock {
  static List<ProveedorModel> getProveedoresPorCategoria(String categoria) {
    // const double baseLat = -8.073506;
    // const double baseLng = -79.057020;

    const double baseLat = -8.095322189711315;
    const double baseLng = -79.04929526003019;

    switch (categoria.toLowerCase()) {
      case 'limpieza':
        return [
          ProveedorModel(
            id: '1',
            nombre: 'Limpieza Express',
            categoria: 'limpieza',
            ubicacion: const LatLng(baseLat + 0.01, baseLng + 0.01),
            calificacion: 4.5,
            resenias: [],
            descripcion: 'Servicio de limpieza profesional',
            imagenUrl: 'assets/images/provider1.jpg',
          ),
          ProveedorModel(
            id: '2',
            nombre: 'Clean Master',
            categoria: 'limpieza',
            ubicacion: const LatLng(baseLat - 0.002, baseLng + 0.012),
            calificacion: 4.8,
            descripcion: 'Limpieza de hogares y oficinas',
            resenias: [],
            imagenUrl: 'assets/images/provider2.jpg',
          ),
          ProveedorModel(
            id: '3',
            nombre: 'Shine Services',
            categoria: 'limpieza',
            ubicacion: const LatLng(baseLat + 0.003, baseLng - 0.013),
            calificacion: 4.2,
            descripcion: 'Limpieza profunda especializada',
            resenias: [],
            imagenUrl: 'assets/images/provider3.jpg',
          ),
          ProveedorModel(
            id: '4',
            nombre: 'Fresh Clean',
            categoria: 'limpieza',
            ubicacion: const LatLng(baseLat - 0.014, baseLng - 0.004),
            calificacion: 4.6,
            descripcion: 'Limpieza ecológica y sostenible',
            resenias: [],
            imagenUrl: 'assets/images/provider4.jpg',
          ),
        ];

      case 'reparador':
        return [
          ProveedorModel(
            id: '5',
            nombre: 'Plomero Express',
            categoria: 'plomería',
            ubicacion: const LatLng(baseLat + 0.013, baseLng + 0.007),
            calificacion: 4.7,
            descripcion: 'Reparaciones de plomería 24/7',
            resenias: [],
            imagenUrl: 'assets/images/plumber1.jpg',
          ),
          ProveedorModel(
            id: '6',
            nombre: 'AquaFix',
            categoria: 'plomería',
            ubicacion: const LatLng(baseLat - 0.008, baseLng + 0.011),
            calificacion: 4.4,
            descripcion: 'Especialistas en tuberías',
            resenias: [],
            imagenUrl: 'assets/images/plumber2.jpg',
          ),
          ProveedorModel(
            id: '7',
            nombre: 'HydroTech',
            categoria: 'plomería',
            ubicacion: const LatLng(baseLat + 0.006, baseLng - 0.015),
            calificacion: 4.9,
            descripcion: 'Instalaciones y reparaciones',
            resenias: [],
            imagenUrl: 'assets/images/plumber3.jpg',
          ),
        ];

      case 'pintor':
        return [
          ProveedorModel(
            id: '8',
            nombre: 'ElectroTech',
            categoria: 'electricidad',
            ubicacion: const LatLng(baseLat - 0.015, baseLng + 0.005),
            calificacion: 4.3,
            descripcion: 'Instalaciones eléctricas profesionales',
            resenias: [],
            imagenUrl: 'assets/images/electric1.jpg',
          ),
          ProveedorModel(
            id: '9',
            nombre: 'Power Solutions',
            categoria: 'electricidad',
            ubicacion: const LatLng(baseLat + 0.004, baseLng + 0.018),
            calificacion: 4.8,
            descripcion: 'Reparaciones eléctricas rápidas',
            resenias: [],
            imagenUrl: 'assets/images/electric2.jpg',
          ),
        ];

      default:
        return [];
    }
  }

  static List<ProveedorModel> getAllProveedores() {
    List<ProveedorModel> todos = [];
    for (var categoria in ['limpieza', 'reparador', 'pintor']) {
      todos.addAll(getProveedoresPorCategoria(categoria));
    }
    return todos;
  }
}
