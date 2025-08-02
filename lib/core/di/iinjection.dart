import 'package:get_it/get_it.dart';
import 'package:serviexpress_app/features/onboarding/data/datasources/local/onboarding_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:serviexpress_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:serviexpress_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:serviexpress_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:serviexpress_app/features/onboarding/domain/usecases/get_onboardingpages_usecase.dart';
import 'package:serviexpress_app/features/onboarding/presentation/viewmodel/onboarding_view_model.dart';

import 'package:serviexpress_app/features/session/data/datasources/session_local_datasource.dart';
import 'package:serviexpress_app/features/session/data/repositories/session_repository_impl.dart';
import 'package:serviexpress_app/features/session/domain/repositories/session_repository.dart';
import 'package:serviexpress_app/features/session/domain/usecases/update_session_usecase.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(
      completeOnboardingUseCase: getIt(),
      getOnboardingPagesUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => CompleteOnboardingUsecase(getIt<UpdateSessionUseCase>()),
  );
  getIt.registerFactory(
    () => GetOnboardingPagesUseCase(getIt<OnboardingRepository>()),
  );

  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: getIt<OnboardingLocalDatasource>(),
    ),
  );

  getIt.registerLazySingleton<OnboardingLocalDatasource>(
    () => OnboardingLocalDatasourceImpl(),
  );

  getIt.registerFactory(() => UpdateSessionUseCase(getIt<SessionRepository>()));

  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(getIt<SessionLocalDatasource>()),
  );

  getIt.registerLazySingleton<SessionLocalDatasource>(
    () => SessionLocalDatasource(sharedPreferences: getIt()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}
