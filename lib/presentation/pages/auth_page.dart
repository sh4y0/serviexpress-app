import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/presentation/viewmodels/auth_view_model.dart';
import 'package:serviexpress_app/presentation/pages/verification.dart';
import 'package:serviexpress_app/presentation/viewmodels/register_view_model.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthPage> {
  bool isLogin = true;
  bool visibilityPasswordIconLogin = true;
  bool visibilityPasswordIconSignup = true;
  final _formLoginKey = GlobalKey<FormState>();
  final _formSignupKey = GlobalKey<FormState>();
  bool isEmployer = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _usuarioControllerRegister =
      TextEditingController();
  final TextEditingController _dniControllerRegister = TextEditingController();
  final TextEditingController _emailControllerRegister =
      TextEditingController();
  final TextEditingController _passwordControllerRegister =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _usuarioControllerRegister.dispose();
    _dniControllerRegister.dispose();
    _emailControllerRegister.dispose();
    _passwordControllerRegister.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResultState>(authViewModelProvider, (previous, next) {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success():
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showSuccessAlert(
              context,
              "Inicio de sesión exitoso",
              onOk: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) => const Verification(),
                  ),
                );
              },
            );
          }
          break;
        case Failure(:final error):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showErrorAlert(context, error.message);
          }
          break;
      }
    });

    ref.listen<ResultState>(registerViewModelProvider, (previous, next) {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success():
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showSuccessAlert(
              context,
              "Usted se ha registrado exitosamente",
              onOk: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a, s) => const Verification(),
                  ),
                );
              },
            );
          }
          break;
        case Failure(:final error):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showErrorAlert(context, error.message);
          }
          break;
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.backgroudGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 24),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedSwitcher(),
              const SizedBox(height: 35),
              AnimatedCrossFade(
                crossFadeState:
                    isLogin
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                firstChild: _buildLoginForm(ref),
                secondChild: _buildSignupForm(ref),
                duration: const Duration(milliseconds: 500),
                firstCurve: Curves.easeOutQuart,
                secondCurve: Curves.easeInQuart,
                sizeCurve: Curves.easeInOutCubic,
                layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                  return Stack(
                    children: [
                      Positioned(key: bottomKey, child: bottomChild),
                      Positioned(key: topKey, child: topChild),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSwitcher() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColor.loginDeselect,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 60) / 2,
              decoration: BoxDecoration(
                color: AppColor.loginSelect,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (!isLogin) {
                      setState(() {
                        isLogin = true;
                      });
                    }
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: isLogin ? Colors.white : AppColor.textDeselect,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (isLogin) {
                      setState(() {
                        isLogin = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: isLogin ? AppColor.textDeselect : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bienvenido",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Welcome back you've been missed!",
          style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formLoginKey,
          child: Column(
            key: const ValueKey('loginForm'),
            children: [
              _buildTextField(
                controller: _emailController,
                hintText: "Usuario",
                svgIconPath: "assets/icons/ic_person.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                hintText: "Constraseña",
                svgIconPath: "assets/icons/ic_pass.svg",
                obscureText: visibilityPasswordIconLogin,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      visibilityPasswordIconLogin =
                          !visibilityPasswordIconLogin;
                    });
                  },
                  icon: Icon(
                    visibilityPasswordIconLogin
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColor.textInput,
                  ),
                ),
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
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      Alerts.instance.showErrorAlert(
                        context,
                        "Por favor completa todos los campos.",
                      );
                      return;
                    }

                    await ref
                        .read(authViewModelProvider.notifier)
                        .loginUser(email, password);
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
                                setState(() {
                                  isLogin = false;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Crea una cuenta",
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Welcome back you've been missed!",
          style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formSignupKey,
          child: Column(
            key: const ValueKey('signupForm'),
            children: [
              _buildTextField(
                controller: _usuarioControllerRegister,
                hintText: "Usuario",
                svgIconPath: "assets/icons/ic_person.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _dniControllerRegister,
                hintText: "DNI",
                svgIconPath: "assets/icons/ic_email.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailControllerRegister,
                hintText: "Correo electronico",
                svgIconPath: "assets/icons/ic_email.svg",
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordControllerRegister,
                hintText: "Contraseña",
                svgIconPath: "assets/icons/ic_pass.svg",
                obscureText: visibilityPasswordIconSignup,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      visibilityPasswordIconSignup =
                          !visibilityPasswordIconSignup;
                    });
                  },
                  icon: Icon(
                    visibilityPasswordIconSignup
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColor.textInput,
                  ),
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
                      side: const BorderSide(
                        color: AppColor.colorInput,
                        width: 1.8,
                      ),
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
                  onPressed: () {
                    final usuario = _usuarioControllerRegister.text.trim();
                    final dni = _dniControllerRegister.text.trim();
                    final email = _emailControllerRegister.text.trim();
                    final password = _passwordControllerRegister.text.trim();

                    if (usuario.isEmpty ||
                        dni.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty) {
                      Alerts.instance.showErrorAlert(
                        context,
                        "Por favor completa todos los campos.",
                      );
                      return;
                    }

                    ref
                        .read(registerViewModelProvider.notifier)
                        .registerUser(email, password, dni, usuario);
                  },
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
                      style: TextStyle(
                        color: AppColor.textWelcome,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColor.textWelcome)),
                ],
              ),
              const SizedBox(height: 10),
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
                                setState(() {
                                  isLogin = true;
                                });
                              },
                      ),
                    ],
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
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 18,
        ),
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
            colorFilter: const ColorFilter.mode(
              AppColor.textInput,
              BlendMode.srcIn,
            ),
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

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
