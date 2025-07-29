class ProveedorSeleccionadoModel {
  final String id;
  final String nombre;
  final double rating;
  final int totalReviews;
  final String especialidad;
  final String? imagePath;

  ProveedorSeleccionadoModel({
    required this.id,
    required this.nombre,
    required this.rating,
    required this.totalReviews,
    required this.especialidad,
    this.imagePath,
  });
}
