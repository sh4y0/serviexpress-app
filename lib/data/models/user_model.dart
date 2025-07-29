import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviexpress_app/data/models/propuesta_model.dart';

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
  final String? criminalRecordUrl;
  final String? signatureUrl;
  final bool isActive;
  final bool isAvailable;
  bool isCompleteProfile;
  PropuestaModel? propuesta;

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
    this.criminalRecordUrl,
    this.signatureUrl,
    this.isActive = true,
    this.isAvailable = true,
    this.isCompleteProfile = false,
    this.propuesta,
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
      dniFrontImageUrl: json['dniFrontImageUrl'] ?? '',
      dniBackImageUrl: json['dniBackImageUrl'] ?? '',
      criminalRecordUrl: json['criminalRecordUrl'] ?? '',
      signatureUrl: json['signatureUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
      isCompleteProfile: json['isCompleteProfile'] ?? true,
      propuesta: json['propuesta'],
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
      'criminalRecordUrl': criminalRecordUrl,
      'signatureUrl': signatureUrl,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'isCompleteProfile': isCompleteProfile,
      'propuesta': propuesta,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? dni,
    String? telefono,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombreCompleto,
    DateTime? createdAt,
    String? rol,
    String? especialidad,
    String? descripcion,
    String? token,
    double? latitud,
    double? longitud,
    String? imagenUrl,
    double? calificacion,
    List<dynamic>? resenias,
    String? dniFrontImageUrl,
    String? dniBackImageUrl,
    String? criminalRecordUrl,
    String? signatureUrl,
    bool? isActive,
    bool? isAvailable,
    bool? isCompleteProfile,
    PropuestaModel? propuesta,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      createdAt: createdAt ?? this.createdAt,
      rol: rol ?? this.rol,
      especialidad: especialidad ?? this.especialidad,
      descripcion: descripcion ?? this.descripcion,
      token: token ?? this.token,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      calificacion: calificacion ?? this.calificacion,
      resenias: resenias ?? this.resenias,
      dniFrontImageUrl: dniFrontImageUrl ?? this.dniFrontImageUrl,
      dniBackImageUrl: dniBackImageUrl ?? this.dniBackImageUrl,
      criminalRecordUrl: criminalRecordUrl ?? this.criminalRecordUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      isCompleteProfile: isCompleteProfile ?? this.isCompleteProfile,
      propuesta: propuesta ?? this.propuesta,
    );
  }
}
