import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/auth/auth_result.dart';
import 'package:serviexpress_app/presentation/viewmodels/auth_view_model.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class _AppIcons {
  static const String person = "assets/icons/ic_person.svg";
  static const String pass = "assets/icons/ic_pass.svg";
  static const String email = "assets/icons/ic_email.svg";
  static const String facebook = "assets/icons/ic_facebook.svg";
  static const String google = "assets/icons/ic_google.svg";
  static const String apple = "assets/icons/ic_apple.svg";
}

class SvgCache {
  static final Map<String, SvgPicture> _cache = {};

  static SvgPicture getIconSvg(
    String assetName, {
    Color color = AppColor.textInput,
  }) {
    final key = '$assetName-$color';
    if (!_cache.containsKey(key)) {
      _cache[key] = SvgPicture.asset(
        assetName,
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return _cache[key]!;
  }
}

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formLoginKey = GlobalKey<FormState>();
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();
  final ValueNotifier<bool> _obscurePasswordLogin = ValueNotifier<bool>(true);

  final _formSignupKey = GlobalKey<FormState>();
  final _usuarioSignupController = TextEditingController();
  final _dniSignupController = TextEditingController();
  final _emailSignupController = TextEditingController();
  final _passwordSignupController = TextEditingController();
  final ValueNotifier<bool> _obscurePasswordSignup = ValueNotifier<bool>(true);

  late Future<void> _preloadFuture;

  final ValueNotifier<bool> _isLogin = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _preloadFuture = Future.wait([MapStyleLoader.loadStyle(), _precacheSvgs()]);
  }

  Future<void> _precacheSvgs() async {
    final svgAssets = [
      _AppIcons.person,
      _AppIcons.pass,
      _AppIcons.email,
      _AppIcons.facebook,
      _AppIcons.google,
      _AppIcons.apple,
    ];

    for (final path in svgAssets) {
      if (!mounted) return;
      SvgCache.getIconSvg(path);
    }
  }

  @override
  void dispose() {
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _obscurePasswordLogin.dispose();
    _usuarioSignupController.dispose();
    _dniSignupController.dispose();
    _emailSignupController.dispose();
    _passwordSignupController.dispose();
    _obscurePasswordSignup.dispose();
    _isLogin.dispose();
    super.dispose();
  }

  void _listenToAuthViewModel() {
    ref.listen<ResultState>(authViewModelProvider, (_, next) {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success(data: final data):
          LoadingScreen.hide();
          if (mounted && data is AuthResult) {
            _handleLoginSuccess(data);
          }
          break;
        case Failure(error: final error):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showErrorAlert(context, error.message);
          }
          break;
      }
    });
  }

  Future<void> _handleLoginSuccess(AuthResult data) async {
    UserPreferences.saveUserId(data.userModel.uid);

    if (data.needsProfileCompletion) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.completeProfile,
          arguments: data.userModel,
        );
      }
      return;
    }

    final role = data.userModel.rol;

    if (data.isNewUser) {
      if (mounted) {
        Alerts.instance.showSuccessAlert(
          context,
          "¡Registro exitoso! Bienvenido a ServiExpress",
          onOk: () => _checkPermissionsAndNavigate(role ?? "Trabajador"),
        );
      }
    } else {
      await _checkPermissionsAndNavigate(role ?? "Cliente");
    }
  }

  Future<void> _checkPermissionsAndNavigate(String role) async {
    if (!mounted) return;

    final permission = await Geolocator.checkPermission();
    final hasPermission =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (hasPermission) {
      final String targetRoute =
          (role == "Trabajador") ? AppRoutes.homeProvider : AppRoutes.home;

      Navigator.pushNamedAndRemoveUntil(
        context,
        targetRoute,
        (route) => false,
        arguments: MapStyleLoader.cachedStyle,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.locationPermissions,
        (route) => false,
        arguments: role,
      );
    }
  }

  void _toggleAuthMode() {
    _isLogin.value = !_isLogin.value;
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuthViewModel();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.backgroudGradient),
        child: FutureBuilder<void>(
          future: _preloadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Error al cargar recursos",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 24),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isLogin,
                builder: (context, isLogin, _) {
                  return Column(
                    children: [
                      _AuthHeader(isLogin: isLogin, onToggle: _toggleAuthMode),
                      const SizedBox(height: 35),
                      AnimatedCrossFade(
                        crossFadeState:
                            isLogin
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                        firstChild: ValueListenableBuilder<bool>(
                          valueListenable: _obscurePasswordLogin,
                          builder: (context, obscurePasswordLogin, _) {
                            return _LoginFormWidget(
                              formKey: _formLoginKey,
                              emailController: _emailLoginController,
                              passwordController: _passwordLoginController,
                              obscurePassword: obscurePasswordLogin,
                              onTogglePasswordVisibility:
                                  () =>
                                      _obscurePasswordLogin.value =
                                          !_obscurePasswordLogin.value,
                              onLogin: _performLogin,
                              onForgotPassword: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.recoveryPassword,
                                );
                              },
                              onSwitchToSignup: _toggleAuthMode,
                              ref: ref,
                            );
                          },
                        ),
                        secondChild: ValueListenableBuilder<bool>(
                          valueListenable: _obscurePasswordSignup,
                          builder: (context, obscurePasswordSignup, _) {
                            return _SignupFormWidget(
                              formKey: _formSignupKey,
                              usuarioController: _usuarioSignupController,
                              dniController: _dniSignupController,
                              emailController: _emailSignupController,
                              passwordController: _passwordSignupController,
                              obscurePassword: obscurePasswordSignup,
                              onTogglePasswordVisibility:
                                  () =>
                                      _obscurePasswordSignup.value =
                                          !_obscurePasswordSignup.value,
                              onSignup: _performSignup,
                              onSwitchToLogin: _toggleAuthMode,
                              ref: ref,
                            );
                          },
                        ),
                        duration: const Duration(milliseconds: 500),
                        firstCurve: Curves.easeOutQuart,
                        secondCurve: Curves.easeInQuart,
                        sizeCurve: Curves.easeInOutCubic,
                        layoutBuilder: (
                          topChild,
                          topKey,
                          bottomChild,
                          bottomKey,
                        ) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(key: bottomKey, child: bottomChild),
                              Positioned(key: topKey, child: topChild),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _performLogin() async {
    if (_formLoginKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();
      final email = _emailLoginController.text.trim();
      final password = _passwordLoginController.text.trim();
      await ref.read(authViewModelProvider.notifier).loginUser(email, password);
    } else {
      Alerts.instance.showErrorAlert(
        context,
        "Por favor completa todos los campos requeridos.",
      );
    }
  }

  void _performSignup() {
    if (_formSignupKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();
      final usuario = _usuarioSignupController.text.trim();
      final email = _emailSignupController.text.trim();
      final password = _passwordSignupController.text.trim();
      ref
          .read(authViewModelProvider.notifier)
          .registerUser(email, password, usuario);
    } else {
      Alerts.instance.showErrorAlert(
        context,
        "Por favor completa todos los campos requeridos.",
      );
    }
  }
}

class _AuthHeader extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const _AuthHeader({required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48 - 12) / 2;

    return RepaintBoundary(
      child: Container(
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
                width: buttonWidth,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.loginSelect,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _AuthHeaderButton(
                    text: "Login",
                    isActive: isLogin,
                    onPressed: () {
                      if (!isLogin) onToggle();
                    },
                  ),
                ),
                Expanded(
                  child: _AuthHeaderButton(
                    text: "Sign Up",
                    isActive: !isLogin,
                    onPressed: () {
                      if (isLogin) onToggle();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHeaderButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const _AuthHeaderButton({
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : AppColor.textDeselect,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CommonAuthFormFields {
  static Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String svgIconPath,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      keyboardType: keyboardType,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
        suffixIconColor: AppColor.textInput,
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio.';
            }
            if (svgIconPath == _AppIcons.email &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Por favor ingresa un correo válido.';
            }
            if (hintText.toLowerCase().contains("contraseña") &&
                value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres.';
            }
            return null;
          },
    );
  }

  static Widget buildPasswordToggleIcon(
    bool isObscured,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
      onPressed: onPressed,
    );
  }
}

class _LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onSwitchToSignup;
  final WidgetRef ref;

  const _LoginFormWidget({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onSwitchToSignup,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loginForm'),
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
          "¡Qué bueno tenerte de vuelta!",
          style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
        ),
        const SizedBox(height: 32),
        Form(
          key: formKey,
          child: Column(
            children: [
              _CommonAuthFormFields.buildTextField(
                controller: emailController,
                hintText: "Usuario o correo electrónico",
                svgIconPath: _AppIcons.person,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              _CommonAuthFormFields.buildTextField(
                controller: passwordController,
                hintText: "Contraseña*",
                svgIconPath: _AppIcons.pass,
                obscureText: obscurePassword,
                suffixIcon: _CommonAuthFormFields.buildPasswordToggleIcon(
                  obscurePassword,
                  onTogglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onForgotPassword,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onLogin,
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
              const _SocialLoginDivider(text: "O inicia sesión con"),
              const SizedBox(height: 20),
              _SocialLoginButtons(
                authViewModelNotifier: ref.read(authViewModelProvider.notifier),
              ),
              const SizedBox(height: 25),
              _AlternateAuthAction(
                promptText: "¿No tienes una cuenta? ",
                actionText: "Registrate Ahora",
                onActionTap: onSwitchToSignup,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignupFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioController;
  final TextEditingController dniController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSignup;
  final VoidCallback onSwitchToLogin;
  final WidgetRef ref;

  const _SignupFormWidget({
    required this.formKey,
    required this.usuarioController,
    required this.dniController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSignup,
    required this.onSwitchToLogin,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signupForm'),
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
          "¡Empecemos! Tu experiencia comienza aquí.",
          style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
        ),
        const SizedBox(height: 32),
        Form(
          key: formKey,
          child: Column(
            children: [
              _CommonAuthFormFields.buildTextField(
                controller: usuarioController,
                hintText: "Usuario",
                svgIconPath: _AppIcons.person,
              ),
              const SizedBox(height: 20),
              _CommonAuthFormFields.buildTextField(
                controller: emailController,
                hintText: "Correo electrónico",
                svgIconPath: _AppIcons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _CommonAuthFormFields.buildTextField(
                controller: passwordController,
                hintText: "Contraseña*",
                svgIconPath: _AppIcons.pass,
                obscureText: obscurePassword,
                suffixIcon: _CommonAuthFormFields.buildPasswordToggleIcon(
                  obscurePassword,
                  onTogglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onSignup,
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
              const SizedBox(height: 20),
              const _SocialLoginDivider(text: "O regístrate con"),
              const SizedBox(height: 20),
              _SocialLoginButtons(
                authViewModelNotifier: ref.read(authViewModelProvider.notifier),
              ),
              const SizedBox(height: 20),
              _AlternateAuthAction(
                promptText: "¿Ya tienes una cuenta? ",
                actionText: "Inicia Sesion",
                onActionTap: onSwitchToLogin,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialLoginDivider extends StatelessWidget {
  final String text;
  const _SocialLoginDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColor.textWelcome)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(color: AppColor.textWelcome, fontSize: 15),
          ),
        ),
        const Expanded(child: Divider(color: AppColor.textWelcome)),
      ],
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  final AuthViewModel authViewModelNotifier;
  const _SocialLoginButtons({required this.authViewModelNotifier});

  Widget _socialButton(String svgPath, VoidCallback onPressed) {
    return Expanded(
      child: SizedBox(
        height: 58,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColor.textWelcome, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: SvgPicture.asset(
            svgPath,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Color(0Xffc0c0c0),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _socialButton(
          _AppIcons.facebook,
          () async => await authViewModelNotifier.loginWithFacebook(),
        ),
        const SizedBox(width: 16),
        _socialButton(
          _AppIcons.google,
          () async => await authViewModelNotifier.loginWithGoogle(),
        ),
        const SizedBox(width: 16),
        _socialButton(_AppIcons.apple, () {
          Alerts.instance.showInfoAlert(
            context,
            "Inicio de sesión con Apple no implementado aún.",
          );
        }),
      ],
    );
  }
}

class _AlternateAuthAction extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;

  const _AlternateAuthAction({
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: promptText,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          children: [
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: AppColor.colorInput,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.colorInput,
              ),
              recognizer: TapGestureRecognizer()..onTap = onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}
