import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/resources/constants/auth/auth_login_string.dart';
import 'package:serviexpress_app/presentation/resources/constants/auth/auth_register_string.dart';

class LoginSignUpSwitcher extends StatelessWidget {
  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;
  const LoginSignUpSwitcher({
    super.key,
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.loginDeselect,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6, right: 6),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onLoginTap,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    isLoginSelected
                        ? AppColor.loginSelect
                        : AppColor.loginDeselect,
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 60),
                  ),
                ),
                child: const Text(
                  AuthLoginString.btnLoginGen,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: onSignUpTap,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    !isLoginSelected
                        ? AppColor.loginSelect
                        : AppColor.loginDeselect,
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 60),
                  ),
                ),
                child: const Text(
                  AuthRegisterString.btnSignUp,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
