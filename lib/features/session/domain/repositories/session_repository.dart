abstract class SessionRepository {
  Future<void> saveUserId(String userId);
  Future<void> saveRole(String role);
  Future<String?> getUserId();
  Future<String?> getRole();
}
