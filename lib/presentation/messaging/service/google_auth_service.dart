import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';

class GoogleAuthService {
  final String serviceAccountPath;
  final List<String> scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  GoogleAuthService(this.serviceAccountPath);

  Future<AutoRefreshingAuthClient> getClient() async {
    final serviceAccountJson = File(serviceAccountPath).readAsStringSync();
    final accountCredentials = ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );
    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  Future<String> getAccessToken() async {
    final client = await getClient();
    final token = client.credentials.accessToken;
    client.close();
    return token.data;
  }
}
