import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class Verifiquemos extends StatefulWidget {
  const Verifiquemos({super.key});

  @override
  State<Verifiquemos> createState() => _VerifiquemosState();
}

class _VerifiquemosState extends State<Verifiquemos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.bgVerification,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Verifiquemos",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Te solicitaremos fotos y archivos adjuntos a continuación.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.textWelcome,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPhotoBox("DNI Lado Frontal"),
                        _buildPhotoBox("DNI Lado Trasero"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPhotoBox("Foto de Perfil", isCircular: true),
                    const SizedBox(height: 20),
                    const Text(
                      "*Verificaremos si tu foto de perfil coincide con la de tu DNI",
                      style: TextStyle(color: AppColor.textInput, fontSize: 14),
                    ),                    
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBox(String label, {bool isCircular = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColor.txtDn, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          width: isCircular ? 120 : 170,
          height: isCircular ? 120 : 120,
          decoration: BoxDecoration(
            color: AppColor.bgCard,
            borderRadius: BorderRadius.circular(isCircular ? 100 : 5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/ic_camera.svg",
                width: 40,
                height: 40,
                colorFilter: ColorFilter.mode(
                  AppColor.btnColor.withAlpha(110),
                  BlendMode.srcIn,
                ),
              ),
              Text(
                "Tomar Foto",
                style: TextStyle(
                  color: AppColor.btnColor.withAlpha(110),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
