import 'package:serviexpress_app/features/onboarding/data/datasources/local/onboarding_local_datasource.dart';

import '../../domain/entities/onboarding_page.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDatasource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OnboardingPage>> getOnboardingPages() async {
    return localDataSource.getOnboardingPages();
  }
}
