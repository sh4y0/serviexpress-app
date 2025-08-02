import 'package:flutter/material.dart';
import 'package:serviexpress_app/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:serviexpress_app/features/onboarding/domain/usecases/get_onboardingpages_usecase.dart';

import '../../domain/entities/onboarding_page.dart';

class OnboardingViewModel with ChangeNotifier {
  final CompleteOnboardingUsecase _completeOnboardingUseCase;
  final GetOnboardingPagesUseCase _getOnboardingPagesUseCase;

  List<OnboardingPage>? pages;
  bool isLoading = true;
  String? errorMessage;

  final PageController pageController = PageController();
  int _currentPageIndex = 0;

  bool get isLastPage =>
      pages != null ? _currentPageIndex == pages!.length - 1 : false;
  int get pageCount => pages?.length ?? 0;

  final ValueNotifier<bool> _navigateToLogin = ValueNotifier(false);
  ValueNotifier<bool> get navigateToLoginEvents => _navigateToLogin;

  OnboardingViewModel({
    required CompleteOnboardingUsecase completeOnboardingUseCase,
    required GetOnboardingPagesUseCase getOnboardingPagesUseCase,
  }) : _completeOnboardingUseCase = completeOnboardingUseCase,
       _getOnboardingPagesUseCase = getOnboardingPagesUseCase {
    _loadPages();
  }

  Future<void> _loadPages() async {
    isLoading = true;
    notifyListeners();

    final result = await _getOnboardingPagesUseCase();

    result.fold(
      ifLeft: (failure) {
        errorMessage = 'Error al cargar las páginas';
      },
      ifRight: (pageList) {
        pages = pageList;
      },
    );

    isLoading = false;
    notifyListeners();
  }

  void onPageChanged(int index) {
    if (_currentPageIndex == index) return;
    _currentPageIndex = index;
    notifyListeners();
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void skip() {
    pageController.jumpToPage(pages!.length - 1);
  }

  Future<void> selectRole(String role) async {
    final result = await _completeOnboardingUseCase(role);
    result.fold(
      ifLeft: (failure) {},
      ifRight: (success) {
        _navigateToLogin.value = true;
      },
    );
  }

  void onNavigationHandled() {
    _navigateToLogin.value = false;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
