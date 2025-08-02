import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}

class SessionLocalDatasource implements LocalStorageService{
  final SharedPreferences sharedPreferences;

  SessionLocalDatasource({required this.sharedPreferences});

  @override
  Future<void> setString(String key, String value) {
    return sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return sharedPreferences.getString(key);
  }

  @override
  Future<void> remove(String key) {
    return sharedPreferences.remove(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    return sharedPreferences.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return sharedPreferences.setBool(key, value);
  }
}
