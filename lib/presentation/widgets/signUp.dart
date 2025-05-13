import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/widgets/common/login_sign_up_switcher.dart';
import 'package:serviexpress_app/presentation/widgets/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLogin = false;
  bool isEmployer = false;

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
                onLoginTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a, s) => const Login(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                onSignUpTap: () {},
              ),
              const SizedBox(height: 35),
              const Text(
                "Crea una cuenta",
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
              _buildTextField(
                hintText: "Usuario",
                svgIconPath: "assets/icons/ic_person.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: "Correo electronico",
                svgIconPath: "assets/icons/ic_email.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                hintText: "Contraseña",
                svgIconPath: "assets/icons/ic_pass.svg",
                obscureText: true,
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_off, color: AppColor.textInput),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: isEmployer,
                      onChanged: (value) {
                        setState(() {
                          isEmployer = value ?? false;
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: AppColor.colorInput,
                      side: const BorderSide(color: AppColor.colorInput, width: 1.8),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Soy empleador",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Registrate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColor.textWelcome)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 65),
                    child: Text(
                      "O",
                      style: TextStyle(color: AppColor.textWelcome, fontSize: 15),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColor.textWelcome)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  socialButton("assets/icons/ic_facebook.svg"),
                  const SizedBox(width: 16),
                  socialButton("assets/icons/ic_google.svg"),
                  const SizedBox(width: 16),
                  socialButton("assets/icons/ic_apple.svg"),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "¿Ya tienes una cuenta? ",
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: "Inicia Sesion",
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
                                    pageBuilder: (c, a, s) => const Login(),
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
