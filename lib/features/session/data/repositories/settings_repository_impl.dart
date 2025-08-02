import 'package:serviexpress_app/features/session/data/datasources/session_local_datasource.dart';
import 'package:serviexpress_app/features/session/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository{
  final LocalStorageService _localStorage;
  static const String _keyTutorial = 'tutorial_mostrado';

  SettingsRepositoryImpl(this._localStorage);
  
  @override
  Future<bool?> hasTutorialBeenShown() async {
     return _localStorage.getBool(_keyTutorial);
  }
  
  @override
  Future<void> setTutorialAsShown(bool isShown) async {
    _localStorage.setBool(_keyTutorial, isShown);
  } 

 

}