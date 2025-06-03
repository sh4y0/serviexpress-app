import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class ServiceComplete {
  final ServiceModel service;
  final UserModel cliente;
  final UserModel trabajador;

  ServiceComplete({
    required this.service,
    required this.cliente,
    required this.trabajador,
  });
}
