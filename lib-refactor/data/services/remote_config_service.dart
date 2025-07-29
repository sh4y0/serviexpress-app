import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._privateConstructor();
  static final RemoteConfigService instance = RemoteConfigService._privateConstructor();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  String? _reniecToken;
  String? _googleMapsKey;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10), 
        minimumFetchInterval: const Duration(hours: 1)
        ),
    );

    await _remoteConfig.fetchAndActivate();

    _reniecToken = _remoteConfig.getString('RENIEC_API_TOKEN');
    _googleMapsKey = _remoteConfig.getString('GOOGLE_MAPS_API_KEY');
  }

  String getReniecToken() {
    return _reniecToken ?? _remoteConfig.getString('RENIEC_API_TOKEN');
  }

  String getGoogleMapsKey() {
    return _googleMapsKey ?? _remoteConfig.getString('GOOGLE_MAPS_API_KEY');
  }
}