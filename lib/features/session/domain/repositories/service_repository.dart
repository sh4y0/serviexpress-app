abstract class ServiceRepository {
  Future<void> saveActiveServiceId(String serviceId);
  Future<String?> getActiveServiceId();
  Future<void> clearActiveServiceId();
}
