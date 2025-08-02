import 'package:flutter/rendering.dart';
import 'package:serviexpress_app/features/session/domain/repositories/session_repository.dart';

class UpdateSessionUseCase {
  final SessionRepository _repository;
  UpdateSessionUseCase(this._repository);

  Future<void> call({String? userId, String? role}) async {
    if (userId != null) {
      await _repository.saveUserId(userId);
    }
    if (role != null) {
      debugPrint('ServiExpress - $role');
      await _repository.saveRole(role);
    }
  }
}
