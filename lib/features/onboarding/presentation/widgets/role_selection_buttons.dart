import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class RoleSelectionButtons extends StatelessWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionButtons({
    super.key, required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            onPressed: () => onRoleSelected('Trabajador'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColor.bgAll),
            ),
            height: 45,
            child: const Text(
              "Trabajador",
              style: TextStyle(
                color: AppColor.bgAll,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MaterialButton(
            onPressed: () => onRoleSelected('Cliente'),
            color: AppColor.bgAll,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            height: 45,
            child: const Text(
              "Cliente",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}