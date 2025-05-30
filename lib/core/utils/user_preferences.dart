import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'user_id';
  static const String _keyRoleName = 'role_name';

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  static Future<void> saveRoleName(String roleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoleName, roleName);
  }

  static Future<String?> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRoleName);
  }

  static Future<void> clearRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoleName);
  }
}
