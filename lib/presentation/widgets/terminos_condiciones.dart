import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:signature/signature.dart';

class TerminosCondiciones extends StatefulWidget {
  final ValueNotifier<bool> aceptado;
  final ValueNotifier<bool> firmado;
  final ValueNotifier<bool> mostrarBotonAceptar;
  const TerminosCondiciones({
    super.key,
    required this.aceptado,
    required this.firmado,
    required this.mostrarBotonAceptar,
  });

  @override
  State<TerminosCondiciones> createState() => _TerminosCondicionesState();
}

class _TerminosCondicionesState extends State<TerminosCondiciones> {
  final SignatureController _firmaController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.white,
    exportBackgroundColor: AppColor.bgCard,
    exportPenColor: Colors.black,
  );

  bool mostrarControles = false;

  void _mostrarFirma() {
    setState(() {
      mostrarControles = true;
      widget.mostrarBotonAceptar.value = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.activeDot,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Firma aquí",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                  color: AppColor.bgCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Signature(
                  controller: _firmaController,
                  width: screenWidth - 40,
                  height: 200,
                  backgroundColor: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _firmaController.clear();
                      widget.firmado.value = false;
                    },
                    icon: const Icon(Icons.clear, color: Colors.red),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (!_firmaController.isEmpty) {
                        widget.firmado.value = true;
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Aceptar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(height: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.bgCard,
                ),
                onPressed: _mostrarFirma,
                child: const Text(
                  "Presiona aquí para firmar",
                  style: TextStyle(color: AppColor.btnColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 30),
              if (mostrarControles)
                Column(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: widget.aceptado,
                      builder:
                          (context, value, _) => Row(
                            children: [
                              Checkbox(
                                value: value,
                                activeColor: AppColor.btnColor,
                                onChanged: (newValue) {
                                  widget.aceptado.value = newValue!;
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  "Aceptar términos y condiciones",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 5),
                    ValueListenableBuilder<bool>(
                      valueListenable: widget.firmado,
                      builder:
                          (context, firmado, _) =>
                              firmado
                                  ? Container(
                                    //alignment: Alignment.centerLeft,
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white30),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Signature(
                                        controller: _firmaController,
                                        width:
                                            MediaQuery.of(context).size.width -
                                            40,
                                        height: 60,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
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
