import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class TerminosCondiciones extends StatefulWidget {
  const TerminosCondiciones({super.key});

  @override
  State<TerminosCondiciones> createState() => _TerminosCondicionesState();
}

class _TerminosCondicionesState extends State<TerminosCondiciones> {
  bool _acepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.bgVerification,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SafeArea(
          child: Column(
            children: [
              const Text(
                "Términos y Condiciones",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "Lorem ipsum dolor sit amet consectetur. Egestas rhoncus pellentesque tristique tellus et sodales turpis eget sit. Vitae ut id varius ultricies feugiat venenatis. Quam dui tortor vitae et in ac consequat. Malesuada tincidunt in scelerisque in id laoreet ligula integer. Sed diam mattis maecenas enim habitant. Ullamcorper tortor vel eleifend sagittis. Fames blandit ultricies sed et. Lorem ipsum dolor sit amet consectetur. Egestas rhoncus pellentesque tristique tellus et sodales turpis eget sit. Vitae ut id varius ultricies feugiat venenatis. Quam dui tortor vitae et in ac consequat. Malesuada tincidunt in scelerisque in id laoreet ligula integer. Sed diam mattis maecenas enim habitant. Ullamcorper tortor vel eleifend sagittis. Fames blandit ultricies sed et. Lorem ipsum dolor sit amet consectetur. Egestas rhoncus pellentesque tristique tellus et sodales turpis eget sit. Vitae ut id varius ultricies feugiat venenatis. Quam dui tortor vitae et in ac consequat. Malesuada tincidunt in scelerisque in id laoreet ligula integer. Sed diam mattis maecenas enim habitant. Ullamcorper tortor vel eleifend sagittis. Fames blandit ultricies sed et.",
                    style: TextStyle(color: AppColor.textWelcome, fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(color: AppColor.btnColor, width: 2),
                    checkColor: Colors.white,
                    activeColor: AppColor.btnColor,
                    value: _acepted,
                    onChanged: (value) {
                      setState(() {
                        _acepted = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    "Aceptar términos y condiciones",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
