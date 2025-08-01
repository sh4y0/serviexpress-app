import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'remote_config_service.dart';

class ReniecService {
  ReniecService._privateConstructor();
  static final ReniecService instance = ReniecService._privateConstructor();

  Future<ResultState<Map<String, dynamic>>> searchByDNI(String dni) async {
    if (dni.isEmpty || dni.length != 8 || int.tryParse(dni) == null) {
      return const Failure(UnknownError("DNI inválido"));
    }

    final String token = RemoteConfigService.instance.getReniecToken();

    if (token.isEmpty) {
      return const Failure(UnknownError("No se pudo consultar a la RENIEC"));
    }

    final Uri url = Uri.parse(
      'https://api.apis.net.pe/v2/reniec/dni?numero=$dni',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Referer': 'https://apis.net.pe/consulta-dni-api',
        },
      );
      if (response.statusCode == 200) {
        try {
          final jsonDecoded = json.decode(response.body);
          if (jsonDecoded is Map<String, dynamic>) {
            return Success(jsonDecoded);
          } else {
            return const Failure(
              UnknownError('Formato de respuesta no válido'),
            );
          }
        } catch (e) {
          return Failure(UnknownError('Error al decodificar el JSON: $e'));
        }
      } else {
        return const Failure(UnknownError('Error HTTP'));
      }
    } catch (e) {
      return Failure(UnknownError('Error desconocido al consultar DNI: $e'));
    }
  }
}
