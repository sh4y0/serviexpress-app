import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/core/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/presentation/login/auth_page.dart';
import 'package:serviexpress_app/presentation/viewmodels/auth_view_model.dart';

class AuthPageRecoveryPassword extends ConsumerStatefulWidget {
  const AuthPageRecoveryPassword({super.key});

  @override
  ConsumerState<AuthPageRecoveryPassword> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthPageRecoveryPassword> {
  final _formRecoveryKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResultState>(authViewModelProvider, (previous, next) async {
      final navigator = Navigator.of(context, rootNavigator: true);

      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success():
          LoadingScreen.hide();
          unawaited(
            Alerts.instance
                .showSuccessAlert(
                  navigator.context,
                  "Se ha enviado un correo de recuperación a tu correo electrónico.",
                )
                .then((_) {
                  navigator.pushReplacementNamed(AppRoutes.login);
                }),
          );
          break;
        case Failure(:final error):
          LoadingScreen.hide();
          Alerts.instance.showErrorAlert(context, error.message);
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.bgChat,
      appBar: AppBar(
        backgroundColor: AppColor.bgChat,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AuthPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        //decoration: const BoxDecoration(gradient: AppColor.backgroudGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(children: [_buildLoginForm(ref)]),
        ),
      ),
    );
  }

  Widget _buildLoginForm(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recuperemos tu contraseña",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Ingresa tu correo!",
          style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formRecoveryKey,
          child: Column(
            key: const ValueKey('loginForm'),
            children: [
              _buildTextField(
                controller: _emailController,
                hintText: "Correo electrónico",
                svgIconPath: "assets/icons/ic_email.svg",
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final email = _emailController.text.trim();

                  if (email.isEmpty) {
                    Alerts.instance.showErrorAlert(
                      context,
                      "Por favor ingresa el correo electrónico.",
                    );
                    return;
                  }

                  await ref
                      .read(authViewModelProvider.notifier)
                      .recoverPassword(email);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.btnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Recuperar Contraseña",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hintText,
    required String svgIconPath,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return TextFormField(
      onTap: () {
        //setState(() {});
      },
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.colorInput, width: 1),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.textInput),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgCache.getIconSvg(svgIconPath),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
