import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  RemoteConfigService._();

  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  String getReniecToken() {
    return _remoteConfig.getString('RENIEC_API_TOKEN');
  }

  String getGoogleMapsKey() {
    return _remoteConfig.getString('GOOGLE_MAPS_API_KEY');
  }
}
