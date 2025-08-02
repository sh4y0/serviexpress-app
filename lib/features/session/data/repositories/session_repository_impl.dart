import 'package:serviexpress_app/features/session/data/datasources/session_local_datasource.dart';
import 'package:serviexpress_app/features/session/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final LocalStorageService _localStorage;

  static const String _keyUserId = 'user_id';
  static const String _keyRoleName = 'role_name';

  SessionRepositoryImpl(this._localStorage);

  @override
  Future<String?> getRole() async {
    return _localStorage.getString(_keyRoleName);
  }

  @override
  Future<String?> getUserId() async {
    return _localStorage.getString(_keyUserId);
  }

  @override
  Future<void> saveRole(String role) async {
    _localStorage.setString(_keyRoleName, role);
  }

  @override
  Future<void> saveUserId(String userId) async {
    _localStorage.setString(_keyUserId, userId);
  }

}
