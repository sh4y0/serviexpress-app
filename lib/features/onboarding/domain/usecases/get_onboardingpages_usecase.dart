import 'package:dart_either/dart_either.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:serviexpress_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:serviexpress_app/core/usecases/usecase.dart';

class GetOnboardingPagesUseCase implements UseCaseWithoutParams<List<OnboardingPage>> {
  final OnboardingRepository repository;

  GetOnboardingPagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnboardingPage>>> call() async {
    try {
      final pages = await repository.getOnboardingPages();
      return Right(pages);
    } catch (e) {
      throw Exception('No se pudieron obtener las páginas'); 
    }
  }
}