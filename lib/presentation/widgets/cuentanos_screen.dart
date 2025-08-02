import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/tell_us_string.dart';
import 'package:serviexpress_app/presentation/widgets/antecedentes.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/show_super.dart';
import 'package:serviexpress_app/presentation/widgets/terminos_condiciones.dart';
import 'package:serviexpress_app/presentation/widgets/verifiquemos.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CuentanosScreen extends ConsumerStatefulWidget {
  final UserModel data;
  const CuentanosScreen({super.key, required this.data});

  @override
  ConsumerState<CuentanosScreen> createState() => _CuentanosScreenState();
}

class _CuentanosScreenState extends ConsumerState<CuentanosScreen> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  final List<String> categorias = [
    "Limpieza",
    "Tecno",
    "Soldadura",
    "Electricidad",
    "Pintura",
    "Plomeria",
    "Stripper",
  ];
  final ValueNotifier<String?> categoriaSeleccionada = ValueNotifier<String?>(
    null,
  );

  final ValueNotifier<bool> _mostrarAceptar = ValueNotifier(false);

  final ValueNotifier<bool> _aceptado = ValueNotifier(false);
  final ValueNotifier<bool> _firmado = ValueNotifier(false);

  final ValueNotifier<bool> _imagenesDniValidas = ValueNotifier(false);
  final ValueNotifier<Uint8List?> _dniFrontImage = ValueNotifier<Uint8List?>(
    null,
  );
  final ValueNotifier<Uint8List?> _dniBackImage = ValueNotifier<Uint8List?>(
    null,
  );
  final ValueNotifier<Uint8List?> _profileImage = ValueNotifier<Uint8List?>(
    null,
  );

  final ValueNotifier<String?> antecedentesFileNameNotifier = ValueNotifier(
    null,
  );

  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _experienciaController = TextEditingController();

  @override
  void dispose() {
    _dniController.dispose();
    _experienciaController.dispose();
    _controller.dispose();
    _aceptado.dispose();
    _firmado.dispose();
    _imagenesDniValidas.dispose();
    _dniFrontImage.dispose();
    _dniBackImage.dispose();
    _profileImage.dispose();
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

  void _onNext() async {
    if (_currentPage.value == 0) {
      if (_dniController.text.isEmpty ||
          categoriaSeleccionada.value == null ||
          _experienciaController.text.isEmpty) {
        Alerts.instance.showErrorAlert(
          context,
          TellUsString.alertCompleteFields,
        );
        return;
      }

      LoadingScreen.show(context);
      try {
        await UserRepository.instance.updateUserCuentanosById({
          "dni": _dniController.text.trim(),
          "especialidad": categoriaSeleccionada.value ?? "",
          "descripcion": _experienciaController.text,
        });
        LoadingScreen.hide();

        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } catch (e) {
        LoadingScreen.hide();
        Alerts.instance.showErrorAlert(context, ErrorMapper.map(e).message);
      }
      return;
    }

    if (_currentPage.value == 1) {
      final bool dniFrontUploaded = _dniFrontImage.value != null;
      final bool dniBackUploaded = _dniBackImage.value != null;
      final bool profileImageUploaded = _profileImage.value != null;

      _imagenesDniValidas.value =
          dniFrontUploaded && dniBackUploaded && profileImageUploaded;

      if (!_imagenesDniValidas.value) {
        Alerts.instance.showErrorAlert(
          context,
          TellUsString.alertUploadDniPhotos,
        );
        return;
      }

      LoadingScreen.show(context);
      await UserRepository.instance.addUserProfilePhoto(_profileImage.value!);
      await UserRepository.instance.addUserDNIPhoto(
        _dniFrontImage.value,
        _dniBackImage.value,
      );
      LoadingScreen.hide();

      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      return;
    }

    if (_currentPage.value == 2) {
      if (antecedentesFileNameNotifier.value == null) {
        Alerts.instance.showErrorAlert(
          context,
          TellUsString.alertUploadCriminalRecord,
        );
        return;
      }
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      return;
    }

    if (_currentPage.value == 3) {
      if (!_aceptado.value) {
        Alerts.instance.showErrorAlert(context, TellUsString.alertAcceptTerms);
        return;
      }

      if (!_firmado.value) {
        Alerts.instance.showErrorAlert(
          context,
          TellUsString.alertSignToContinue,
        );
        return;
      }

      Alerts.instance.showSuccessAlert(
        context,
        TellUsString.successMessage,
        onOk: () async {
          await UserRepository.instance.updateUserCuentanosById({
            "isCompleteProfile": true,
          });

          final permission = await Geolocator.checkPermission();
          final hasPermission =
              permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse;
          if (!hasPermission) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.locationPermissions,
              arguments: widget.data.rol,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.homeProvider,
              arguments: MapStyleLoader.cachedStyle,
            );
          }
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColor.bgVerification),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, currentPage, _) {
                    return AnimatedSmoothIndicator(
                      activeIndex: currentPage,
                      count: 4,
                      effect: const WormEffect(
                        radius: 2,
                        dotHeight: 10,
                        dotWidth: 75,
                        activeDotColor: AppColor.btnColor,
                        dotColor: AppColor.bgMsgUser,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => _currentPage.value = index,
                  children: [
                    _buildCuentanosPaso(),
                    Verifiquemos(
                      dniFrontImage: _dniFrontImage,
                      dniBackImage: _dniBackImage,
                      profileImage: _profileImage,
                    ),
                    Antecedentes(
                      fileNameNotifier: antecedentesFileNameNotifier,
                    ),
                    TerminosCondiciones(
                      aceptado: _aceptado,
                      onAceptar: () {
                        _onNext();
                      },
                      firmado: _firmado,
                    ),
                    //const Verification(),
                  ],
                ),
              ),

              ValueListenableBuilder2<int, bool>(
                first: _currentPage,
                second: _mostrarAceptar,
                builder: (context, currentPage, _, __) {
                  if (currentPage == 3) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (currentPage > 0)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.bgCard,
                              ),
                              onPressed: () {
                                _controller.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text(
                                TellUsString.back,
                                style: TextStyle(
                                  color: AppColor.bgAll,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        if (currentPage > 0) const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onNext,
                            child: const Text(
                              TellUsString.next,
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
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCuentanosPaso() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            TellUsString.tellUsMore,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            TellUsString.moreInformationAboutYou,
            style: TextStyle(fontSize: 14, color: AppColor.textWelcome),
          ),
          const SizedBox(height: 30),
          _buildTextFieldDNI(),
          const SizedBox(height: 20),
          ValueListenableBuilder<String?>(
            valueListenable: categoriaSeleccionada,
            builder: (context, value, _) {
              return _buildDropdownCategoria(value);
            },
          ),
          const SizedBox(height: 20),
          _buildTextFieldExperiencia(),
        ],
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
        hintText: TellUsString.hintEnterYourDni,
        hintStyle: const TextStyle(color: AppColor.textInput),
      ),
    );
  }

  Widget _buildDropdownCategoria(String? selectedValue) {
    return DropdownButtonFormField2<String>(
      value: selectedValue,
      items:
          categorias.map((String categoria) {
            return DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria),
            );
          }).toList(),
      onChanged: (String? newValue) {
        categoriaSeleccionada.value = newValue;
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
        TellUsString.hintSelectCategory,
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
        hintText: TellUsString.hintDescribeYourself,
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

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, valueA, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, valueB, child) {
            return builder(context, valueA, valueB, child);
          },
        );
      },
    );
  }
}
