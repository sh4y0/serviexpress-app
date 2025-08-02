
import 'package:dart_either/dart_either.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/usecases/usecase.dart';
import 'package:serviexpress_app/features/session/domain/usecases/update_session_usecase.dart';

class CompleteOnboardingUsecase implements UseCaseWithParams<String> {
  final UpdateSessionUseCase _updateSessionUseCase; 

  CompleteOnboardingUsecase(this._updateSessionUseCase);

  @override
  Future<Either<Failure, void>> call(String role) async {
    try {
      await _updateSessionUseCase(role: role);
      
      return const Right(null);
    } catch (e) {
      throw Exception('No se ha podido guardar el rol');
    }
  }
}
