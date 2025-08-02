import '../entities/onboarding_page.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingPage>> getOnboardingPages();
}