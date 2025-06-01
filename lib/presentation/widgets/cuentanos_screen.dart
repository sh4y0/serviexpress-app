import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';
import 'package:serviexpress_app/presentation/viewmodels/user_view_model.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/show_super.dart';

class CuentanosScreen extends ConsumerStatefulWidget {
  final UserModel data;
  const CuentanosScreen({super.key, required this.data});

  @override
  ConsumerState<CuentanosScreen> createState() => _CuentanosScreenState();
}

class _CuentanosScreenState extends ConsumerState<CuentanosScreen> {
  final List<String> categorias = ["Limpieza", "Pintura", "Otro"];
  String? categoriaSeleccionada;

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _experienciaController = TextEditingController();
  late Future<void> _preloadFuture;

  @override
  void initState() {
    super.initState();
    _preloadFuture = Future.wait([MapStyleLoader.loadStyle(), _precacheSvgs()]);

  }

  Future<void> _precacheSvgs() async {
    final svgPaths = [
      "assets/icons/ic_person.svg",
      "assets/icons/ic_pass.svg",
      "assets/icons/ic_email.svg",
      "assets/icons/ic_facebook.svg",
      "assets/icons/ic_google.svg",
      "assets/icons/ic_apple.svg",
    ];

    for (final path in svgPaths) {
      SvgCache.getIconSvg(path);
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _experienciaController.dispose();
    super.dispose();
  }

  void mostrarAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: ShowSuper(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResultState>(userViewModelProvider, (previous, next) async {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          _preloadFuture;
          LoadingScreen.show(context);
          break;
        case Success():
          LoadingScreen.hide();
          if (mounted) {
            await UserPreferences.saveUserId(widget.data.uid);

            Alerts.instance.showSuccessAlert(
              context,
              "Ahora puedes disfrutar de nuestros servicios.",
              onOk: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.homeProvider,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.backgroudGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cuéntanos mas de ti",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Nos gustaría saber de ti por ello te pediremos alguna información adicional.",
                  style: TextStyle(fontSize: 17, color: AppColor.textWelcome),
                ),
                const SizedBox(height: 30),
                Form(
                  child: Column(
                    children: [
                      _buildTextFieldDNI(),
                      const SizedBox(height: 20),
                      _buildDropdownCategoria(),
                      const SizedBox(height: 20),
                      _buildTextFieldExperiencia(),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: AppColor.btnColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            if (_dniController.text.isEmpty ||
                                categoriaSeleccionada == null ||
                                _experienciaController.text.isEmpty) {
                              Alerts.instance.showErrorAlert(
                                context,
                                "Por favor, completa todos los campos.",
                              );
                              return;
                            }

                            ref
                                .read(userViewModelProvider.notifier)
                                .updateUserById(widget.data.uid, {
                                  "dni": _dniController.text.trim(),
                                  "especialidad": categoriaSeleccionada,
                                  "descripcion":
                                      _experienciaController.text.trim(),
                                });
                          },
                          child: const Text(
                            "Finalizar Registro",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldDNI({
    //required String svgIconPath,
    bool obscureText = false,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      maxLength: 8,
      controller: _dniController,
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        counterText: "",
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
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
        hintText: "Ingresa tu DNI",
        hintStyle: const TextStyle(color: AppColor.textInput),
      ),
    );
  }

  Widget _buildDropdownCategoria() {
    return DropdownButtonFormField2<String>(
      value: categoriaSeleccionada,
      items:
          categorias.map((String categoria) {
            return DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          categoriaSeleccionada = newValue;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.only(top: 18, bottom: 18, right: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
      ),
      hint: const Text(
        "Escoge tu categoria",
        style: TextStyle(color: AppColor.textInput, fontSize: 16),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: AppColor.bgChat,
          borderRadius: BorderRadius.circular(14),
        ),
        offset: const Offset(0, -4),
      ),
      iconStyleData: IconStyleData(
        icon: SvgPicture.asset(
          "assets/icons/ic_down.svg",
          // ignore: deprecated_member_use
          color: AppColor.textInput,
        ),
      ),
      style: const TextStyle(color: AppColor.textInput, fontSize: 16),
    );
  }

  Widget _buildTextFieldExperiencia() {
    return TextField(
      controller: _experienciaController,
      maxLines: 8,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        hintText: "Descríbete brevemente, cuéntanos tu experiencia,..",
        hintStyle: const TextStyle(color: AppColor.textInput),
        filled: true,
        fillColor: Colors.transparent,
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
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
      ),
    );
  }
}
