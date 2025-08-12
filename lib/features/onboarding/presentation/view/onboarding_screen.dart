import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/config/app_routes.dart';
import 'package:serviexpress_app/core/di/iinjection.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/features/onboarding/presentation/widgets/onboarding_controls.dart';
import 'package:serviexpress_app/features/onboarding/presentation/widgets/onboarding_indicator.dart';
import 'package:serviexpress_app/features/onboarding/presentation/widgets/onboarding_page_view.dart';

import '../viewmodel/onboarding_view_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<OnboardingViewModel>();
    _viewModel.navigateToLoginEvents.addListener(_handleNavigation);
  }

  @override
  void dispose() {
    _viewModel.navigateToLoginEvents.removeListener(_handleNavigation);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavigation() {
    if (_viewModel.navigateToLoginEvents.value == true && context.mounted) {
      Navigator.pushNamed(context, AppRoutes.login);
      _viewModel.onNavigationHandled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColor.bgOnBoar,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 10,
                  child: OnboardingPageView(viewModel: _viewModel),
                ),

                Expanded(
                  flex: 1,
                  child: OnboardingIndicator(viewModel: _viewModel),
                ),

                Expanded(
                  flex: 2,
                  child: OnboardingControls(viewModel: _viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
