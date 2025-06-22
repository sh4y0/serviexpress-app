import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String id;
  String? categoria;
  String descripcion;
  String estado;
  String clientId;
  String? workerId;
  List<String>? fotos;
  List<String>? videos;
  List<String>? audios;
  DateTime? fechaCreacion;
  DateTime? fechaFinalizacion;
  List<File>? fotosFiles;
  List<File>? videosFiles;
  List<File>? audioFiles;
  Set<String>? workersId;
  String? propuestaId;

  ServiceModel({
    required this.id,
    this.categoria,
    required this.descripcion,
    required this.estado,
    required this.clientId,
    this.workerId,
    this.fotos,
    this.videos,
    this.audios,
    this.fechaCreacion,
    this.fechaFinalizacion,
    this.fotosFiles,
    this.videosFiles,
    this.audioFiles,
    this.workersId,
    this.propuestaId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      categoria: json['categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? '',
      clientId: json['clientId'] ?? '',
      workerId: json['workerId'] ?? '',
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : null,
      videos: json['videos'] != null ? List<String>.from(json['videos']) : null,
      audios: json['audios'] != null ? List<String>.from(json['audios']) : null,
      fechaCreacion:
          json['fechaCreacion'] != null
              ? (json['fechaCreacion'] as Timestamp).toDate()
              : null,
      fechaFinalizacion:
          json['fechaFinalizacion'] != null
              ? (json['fechaFinalizacion'] as Timestamp).toDate()
              : null,
      workersId:
          json['workersId'] != null
              ? Set<String>.from(json['workersId'])
              : null,
      propuestaId: json['propuestaId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'descripcion': descripcion,
      'estado': estado,
      'clientId': clientId,
      'workerId': workerId,
      'fotos': fotos,
      'videos': videos,
      'audios': audios,
      'fechaCreacion':
          fechaCreacion != null ? Timestamp.fromDate(fechaCreacion!) : null,
      'fechaFinalizacion':
          fechaFinalizacion != null
              ? Timestamp.fromDate(fechaFinalizacion!)
              : null,
      'workersId': workersId,
      'propuestaId': propuestaId ?? '',
    };
  }
}
