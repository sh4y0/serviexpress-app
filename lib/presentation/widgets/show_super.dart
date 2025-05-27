import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class ShowSuper extends StatelessWidget {
  final VoidCallback? onClose;
  const ShowSuper({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 400 ? 400 : double.infinity,
          ),
          child: Stack(
            children: [
              Material(
                color: AppColor.loginDeselect,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Image(image: AssetImage("assets/gifs/acepted.gif")),
                      const SizedBox(height: 30),
                      const Text(
                        "Super! Has aceptado a Fedor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Fedor podrá empezar con el servicio después de que realices el pago. Recuerda el pago no se le dará a Fedor hasta que haya terminado la tarea con éxito.",
                        style: TextStyle(color: AppColor.txtPropuesta),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.btnOpen,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Ir al inicio",
                            style: TextStyle(
                              color: AppColor.bgAll,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 15,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
