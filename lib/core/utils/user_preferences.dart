import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'user_id';
  static const String _keyRoleName = 'role_name';
  static const String _keyTutorial = 'tutorial_mostrado';
  static const String _keyServiceId = 'service_id';
  static final ValueNotifier<String?> activeServiceId = ValueNotifier(null);

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
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  static Future<void> saveTutorial(bool isMostrado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorial, isMostrado);
  }

  static Future<bool?> getSavedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorial);
  }

  static Future<void> clearSaveTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorial);
  }

  static Future<void> saveServiceId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServiceId, userId);
  }

  static Future<String?> getServiceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServiceId);
  }

  static Future<void> clearServiceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyServiceId);
  }
}
