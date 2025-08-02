abstract class SettingsRepository {
  Future<void> setTutorialAsShown(bool isShown);
  Future<bool?> hasTutorialBeenShown();
}
