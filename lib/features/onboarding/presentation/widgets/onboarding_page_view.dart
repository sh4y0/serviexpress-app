import 'package:flutter/widgets.dart';
import 'package:serviexpress_app/features/onboarding/presentation/viewmodel/onboarding_view_model.dart';
import 'onboarding_content.dart';

class OnboardingPageView extends StatelessWidget {
  final OnboardingViewModel viewModel;

  const OnboardingPageView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    //assert(viewModel.pages != null, 'Pages cannot be null when building OnboardingPageView');

    return PageView.builder(
      controller: viewModel.pageController,
      onPageChanged: viewModel.onPageChanged,
      itemCount: viewModel.pageCount,
      itemBuilder: (context, index) {
        final pageData = viewModel.pages![index];
        return OnboardingContent(
          image: pageData.imagePath,
          title: pageData.title,
          description: pageData.description,
        );
      },
    );
  }
}