import 'package:flutter/widgets.dart';
import 'package:serviexpress_app/features/onboarding/presentation/viewmodel/onboarding_view_model.dart';
import 'role_selection_buttons.dart';
import 'navigation_buttons.dart';

class OnboardingControls extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const OnboardingControls({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child:
          viewModel.isLastPage
              ? RoleSelectionButtons(onRoleSelected: viewModel.selectRole)
              : NavigationButtons(
                onSkip: viewModel.skip,
                onNext: viewModel.nextPage,
              ),
    );
  }
}
