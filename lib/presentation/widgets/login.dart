import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/widgets/common/login_sign_up_switcher.dart';
import 'package:serviexpress_app/presentation/widgets/signUp.dart';
import 'package:serviexpress_app/presentation/widgets/verification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.backgroudGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoginSignUpSwitcher(
                isLoginSelected: isLogin,
                onLoginTap: () {},
                onSignUpTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a, s) => const SignUp(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(height: 35),
              const Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Welcome back you’ve been missed!",
                style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  _buildTextField(
                    hintText: "Usuario",
                    svgIconPath: "assets/icons/ic_person.svg",
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    hintText: "Constraseña",
                    svgIconPath: "assets/icons/ic_pass.svg",
                    obscureText: true,
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_off, color: AppColor.textInput),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text(
                    "Olvidaste tu contraseña?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a, s) => const Verification(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Iniciar Sesion",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColor.textWelcome)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "O inicia sesión con",
                      style: TextStyle(
                        color: AppColor.textWelcome,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColor.textWelcome)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: socialButton("assets/icons/ic_facebook.svg")),
                  const SizedBox(width: 16),
                  Expanded(child: socialButton("assets/icons/ic_google.svg")),
                  const SizedBox(width: 16),
                  Expanded(child: socialButton("assets/icons/ic_apple.svg")),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "¿No tienes una cuenta? ",
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: "Registrate Ahora",
                        style: const TextStyle(
                          color: AppColor.colorInput,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (c, a, s) => const SignUp(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* Diseño de los inputs */
  Widget _buildTextField({
    required String hintText,
    required String svgIconPath,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.colorInput, width: 2),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.textInput),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(
            svgIconPath,
            width: 26,
            height: 26,
            // ignore: deprecated_member_use
            color: AppColor.textInput,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  /* DISEÑO DE LAS REDES SOCIALES PARA INCIAR SESION */
  Widget socialButton(String svgPath) {
    return SizedBox(
      width: 100,
      height: 58,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.textWelcome, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: SvgPicture.asset(svgPath, width: 26, height: 26),
      ),
    );
  }
}
