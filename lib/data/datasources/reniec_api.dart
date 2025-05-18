import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/service/remote_config_service.dart';

class ReniecApi {
  ReniecApi._privateConstructor();
  static final ReniecApi instance = ReniecApi._privateConstructor();

  final String _token = RemoteConfigService.instance.getReniecToken();

  Future<ResultState<Map<String, dynamic>>> searchByDNI(String dni) async {
    final Uri url = Uri.parse(
      'https://api.apis.net.pe/v2/reniec/dni?numero=$dni',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Referer': 'https://apis.net.pe/consulta-dni-api',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Success(data);
      } else {
        return Failure(
          UnknownError(
            "Error ${response.statusCode}: ${response.reasonPhrase}",
          ),
        );
      }
    } catch (e) {
      return Failure(UnknownError("Excepción al consultar DNI: $e"));
    }
  }
}
