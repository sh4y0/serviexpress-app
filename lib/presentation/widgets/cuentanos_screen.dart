import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/widgets/show_super.dart';

class CuentanosScreen extends StatefulWidget {
  const CuentanosScreen({super.key});

  @override
  State<CuentanosScreen> createState() => _CuentanosScreenState();
}

class _CuentanosScreenState extends State<CuentanosScreen> {
  final List<String> categorias = ["Limpieza", "Pintura", "Otro"];
  String? categoriaSeleccionada;

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
                      _buildTextFieldDNI(hintText: "DNI"),
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
                          onPressed: mostrarAlert,
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
    required String hintText,
    //required String svgIconPath,
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      maxLength: 8,
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.textInput, width: 1),
        ),
        hintText: hintText,
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
          color: AppColor.textInput,
        ),
      ),
      style: const TextStyle(color: AppColor.textInput, fontSize: 16),
    );
  }

  Widget _buildTextFieldExperiencia() {
    return TextField(
      maxLines: 8,
      cursorColor: AppColor.colorInput,
      style: const TextStyle(color: AppColor.textInput),
      decoration: InputDecoration(
        hintText: "Descríbete brevemente, cuéntanos tu experiencia,..",
        hintStyle: const TextStyle(color: AppColor.textInput),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
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
