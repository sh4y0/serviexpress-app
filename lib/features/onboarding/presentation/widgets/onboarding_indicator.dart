import 'package:flutter/widgets.dart';
import 'package:serviexpress_app/features/onboarding/presentation/viewmodel/onboarding_view_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class OnboardingIndicator extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const OnboardingIndicator({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SmoothPageIndicator(
        controller: viewModel.pageController,
        count: viewModel.pageCount,
        effect: const ExpandingDotsEffect(
          activeDotColor: AppColor.activeDot,
          dotColor: AppColor.dotColor,
          dotHeight: 8,
          dotWidth: 10,
        ),
      ),
    );
  }
}
