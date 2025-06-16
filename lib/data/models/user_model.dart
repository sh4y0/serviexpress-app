import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String dni;
  final String telefono;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreCompleto;
  final DateTime? createdAt;
  final String? rol;
  final String? especialidad;
  final String? descripcion;
  final String? token;
  final double? latitud;
  final double? longitud;
  final String? imagenUrl;
  final double? calificacion;
  final List<dynamic>? resenias;
  final String? dniFrontImageUrl;
  final String? dniBackImageUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.dni,
    required this.telefono,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombreCompleto,
    this.createdAt,
    this.rol,
    this.especialidad,
    this.descripcion,
    this.token,
    this.latitud,
    this.longitud,
    this.imagenUrl,
    this.calificacion,
    this.resenias,
    this.dniFrontImageUrl,
    this.dniBackImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      dni: json['dni'] ?? '',
      telefono: json['telefono'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
      rol: json['rol'],
      especialidad: json['especialidad'],
      descripcion: json['descripcion'],
      token: json['token'],
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      imagenUrl: json['imagenUrl'],
      calificacion: json['calificacion']?.toDouble() ?? 0.0,
      resenias:
          json['resenias'] is List
              ? json['resenias']
              : (json['resenias'] as List<dynamic>?) ?? [],
      dniFrontImageUrl: json['dniFrontImageUrl'],
      dniBackImageUrl: json['dniBackImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'dni': dni,
      'telefono': telefono,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'nombreCompleto': nombreCompleto,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'rol': rol,
      'especialidad': especialidad,
      'descripcion': descripcion,
      'token': token,
      'latitud': latitud,
      'longitud': longitud,
      'imagenUrl': imagenUrl ?? '',
      'calificacion': calificacion ?? 0.0,
      'resenias': resenias is List ? resenias : (resenias ?? []),
      'dniFrontImageUrl': dniFrontImageUrl,
      'dniBackImageUrl': dniBackImageUrl,
    };
  }
}
