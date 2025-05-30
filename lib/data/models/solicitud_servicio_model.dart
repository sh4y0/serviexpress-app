import 'dart:io';

class SolicitudServicioModel {
  String? categoria;
  String? descripcion;
  List<File> fotos; 
  List<File> videos;

  SolicitudServicioModel({
    this.categoria,
    this.descripcion,
    this.fotos = const [],
    this.videos = const [],
  });

  bool get hasData =>
      categoria != null ||
      (descripcion != null && descripcion!.isNotEmpty) ||
      fotos.isNotEmpty ||
      videos.isNotEmpty;

  void clear() {
    categoria = null;
    descripcion = null;
    fotos = [];
    videos = [];
  }

  @override
  String toString() {
    return 'SolicitudServicioData(categoria: $categoria, descripcion: $descripcion, fotos: ${fotos.length}, videos: ${videos.length})';
  }
}