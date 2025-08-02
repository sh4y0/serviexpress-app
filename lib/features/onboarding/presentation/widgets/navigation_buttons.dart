import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const NavigationButtons({
    super.key,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MaterialButton(
          onPressed: onSkip,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: const Text(
            "Saltar",
            style: TextStyle(color: AppColor.bgAll, fontSize: 16),
          ),
        ),
        MaterialButton(
          onPressed: onNext,
          color: AppColor.bgAll,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minWidth: 56,
          height: 56,
          padding: EdgeInsets.zero,
          child: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ],
    );
  }
}
