import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/notification_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  FirebaseMessagingService._internal();

  static FirebaseMessagingService get instance => _instance;

  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final String _serviceAccountPath = 'assets/serviexpressapp.json';

  final String _projectId = 'serviexpressapp-7e391';

  Future<bool> sendFCMMessage(FCMMessage message, String userId) async {
    try {
      final deviceToken = await _getDeviceToken(userId);

      if (deviceToken == null || deviceToken.isEmpty) {
        return false;
      }

      final messageWithToken = message.copyWith(token: deviceToken);

      final json = await rootBundle.loadString(_serviceAccountPath);
      final credentials = ServiceAccountCredentials.fromJson(json);

      final client = await clientViaServiceAccount(credentials, _scopes);
      final token = client.credentials.accessToken.data;

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );

      final requestBody = jsonEncode(messageWithToken.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        await NotificationRepository.instance.saveNotification(
          messageWithToken,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getDeviceToken(String userId) async {
    final result = await UserRepository.instance.getUserById(userId);

    if (result is Success<UserModel>) {
      final token = result.data.token;
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } else if (result is Failure) {
      return null;
    }
    return null;
  }
}
