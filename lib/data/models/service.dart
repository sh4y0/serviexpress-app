import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class Service {
  final ServiceModel service;
  final UserModel cliente;
  final UserModel trabajador;

  Service({
    required this.service,
    required this.cliente,
    required this.trabajador,
  });
}
