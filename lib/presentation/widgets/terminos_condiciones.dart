import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:signature/signature.dart';

class TerminosCondiciones extends StatefulWidget {
  final ValueNotifier<bool> aceptado;
  final ValueNotifier<bool> firmado;
  final VoidCallback? onAceptar;

  const TerminosCondiciones({
    super.key,
    required this.aceptado,
    this.onAceptar,
    required this.firmado,
  });

  @override
  State<TerminosCondiciones> createState() => _TerminosCondicionesState();
}

class _TerminosCondicionesState extends State<TerminosCondiciones> {
  final ValueNotifier<Uint8List?> firmaNotifier = ValueNotifier<Uint8List?>(
    null,
  );

  void _mostrarOpciones() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.3,
          maxChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return Scaffold(
              backgroundColor: AppColor.bgVerification,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: widget.aceptado,
                      builder:
                          (context, value, _) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: value,
                                activeColor: AppColor.btnColor,
                                checkColor: Colors.white,
                                side: const BorderSide(
                                  color: AppColor.btnColor,
                                  width: 1.5,
                                ),
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
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        ValueListenableBuilder<Uint8List?>(
                          valueListenable: firmaNotifier,
                          builder: (context, firma, _) {
                            return GestureDetector(
                              onTap: () async {
                                final resultado = await Navigator.of(
                                  context,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (context) => const Firmar(),
                                  ),
                                );
                                if (resultado != null &&
                                    resultado is Uint8List) {
                                  firmaNotifier.value = resultado;
                                  widget.firmado.value = true;
                                  LoadingScreen.show(context);
                                  await UserRepository.instance
                                      .addUserSignature(firmaNotifier.value!);
                                  LoadingScreen.hide();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: AppColor.bgCard,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    firma != null
                                        ? Image.memory(
                                          firma,
                                          fit: BoxFit.contain,
                                        )
                                        : const Center(
                                          child: Text(
                                            "Toca para firmar",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              firmaNotifier.value = null;
                              widget.firmado.value = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1),
                                  content: Text(
                                    "Firma eliminada",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.red[100],
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/ic_delete.svg",
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final resultado = await Navigator.of(
                                context,
                              ).push(
                                MaterialPageRoute(
                                  builder: (context) => const Firmar(),
                                ),
                              );
                              if (resultado != null && resultado is Uint8List) {
                                firmaNotifier.value = resultado;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppColor.btnColor,
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.aceptado.value) {
                          widget.onAceptar?.call();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                              content: Text(
                                "Debes aceptar los términos para continuar.",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Aceptar",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    firmaNotifier.dispose();
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.bgCard,
                ),
                onPressed: _mostrarOpciones,
                child: const Text(
                  "Presiona aquí para firmar",
                  style: TextStyle(color: AppColor.btnColor, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Firmar extends StatefulWidget {
  const Firmar({super.key});

  @override
  State<Firmar> createState() => _FirmarState();
}

class _FirmarState extends State<Firmar> {
  final SignatureController _firmaController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.white,
    exportBackgroundColor: AppColor.bgCard,
    exportPenColor: Colors.white,
  );

  @override
  void dispose() {
    _firmaController.dispose();
    super.dispose();
  }

  void _guardarFirma() async {
    if (_firmaController.isNotEmpty) {
      final signature = await _firmaController.toPngBytes();

      if (signature != null && signature.isNotEmpty) {
        Navigator.pop(context, signature);
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
        content: Text(
          "Por favor, firma antes de continuar.",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _limpiarFirma() {
    _firmaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      appBar: AppBar(
        backgroundColor: AppColor.bgVerification,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
        title: const Text(
          "Firma aquí",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      color: AppColor.bgCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Signature(
                      controller: _firmaController,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: _limpiarFirma,
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _guardarFirma,
                child: const Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
