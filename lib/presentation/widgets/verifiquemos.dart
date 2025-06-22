import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class Verifiquemos extends StatefulWidget {
  final ValueNotifier<File?> dniFrontImage;
  final ValueNotifier<File?> dniBackImage;
  final ValueNotifier<File?> profileImage;

  const Verifiquemos({
    super.key,
    required this.dniFrontImage,
    required this.dniBackImage,
    required this.profileImage,
  });

  @override
  State<Verifiquemos> createState() => _VerifiquemosState();
}

class _VerifiquemosState extends State<Verifiquemos> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, String type) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      switch (type) {
        case "front":
          widget.dniFrontImage.value = file;
          break;
        case "back":
          widget.dniBackImage.value = file;
          break;
        case "profile":
          widget.profileImage.value = file;
          break;
      }
    }
  }

  void _showPickerOptions(String type) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColor.bgCard,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Tomar Foto"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera, type);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Elegir de Galería"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery, type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                  style: TextStyle(fontSize: 14, color: AppColor.textWelcome),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildPhotoBox(
                        "DNI Lado Frontal",
                        widget.dniFrontImage,
                        "front",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPhotoBox(
                        "DNI Lado Trasero",
                        widget.dniBackImage,
                        "back",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPhotoBox(
                  "Foto de Perfil",
                  widget.profileImage,
                  "profile",
                  isCircular: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  "*Verificaremos si tu foto de perfil coincide con la de tu DNI",
                  style: TextStyle(color: AppColor.textInput, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBox(
    String label,
    ValueNotifier<File?> imageNotifier,
    String type, {
    bool isCircular = false,
  }) {
    return GestureDetector(
      onTap: () => _showPickerOptions(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColor.txtDn, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<File?>(
            valueListenable: imageNotifier,
            builder: (context, imageFile, _) {
              return Container(
                width: isCircular ? 120 : 170,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColor.bgCard,
                  borderRadius: BorderRadius.circular(isCircular ? 100 : 5),
                  image:
                      imageFile != null
                          ? DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    imageFile == null
                        ? Column(
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
                        )
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
