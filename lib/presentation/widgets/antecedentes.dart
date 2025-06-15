import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class Antecedentes extends StatefulWidget {
  const Antecedentes({super.key});

  @override
  State<Antecedentes> createState() => _AntecedentesState();
}

class _AntecedentesState extends State<Antecedentes> {
  final ValueNotifier<String?> _fileNameNotifier = ValueNotifier<String?>(null);

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "dcx"],
    );
    if (result != null) {
      _fileNameNotifier.value = result.files.single.name;
    } else {
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fileNameNotifier.dispose();    
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
                  "Ya casi..",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Necesitamos saber si cuentas con algún antecedente, esto para verificar que estas limpio.",
                  style: TextStyle(color: AppColor.textWelcome, fontSize: 14),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColor.bgCard,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColor.btnColor.withAlpha(110),
                          size: 50,
                        ),
                        ValueListenableBuilder<String?>(
                          valueListenable: _fileNameNotifier,
                          builder: (context, value, _) {
                            return Text(
                              value ?? "Subir archivo",
                              style: TextStyle(
                                color: AppColor.btnColor.withAlpha(110),
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "*Subir formato PDF o DCX",
                  style: TextStyle(color: AppColor.textInput, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
