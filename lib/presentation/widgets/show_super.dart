import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class ShowSuper extends StatelessWidget {
  final VoidCallback? onClose;
  final UserModel? provider;
  final LatLng? clientPosition;

  const ShowSuper({
    super.key,
    this.onClose,
    this.provider,
    this.clientPosition,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(22, 26, 80, 1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 400 ? 400 : double.infinity,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Image(image: AssetImage("assets/gifs/acepted.gif")),
                      const SizedBox(height: 30),
                      Text(
                        "Super! Has aceptado a ${provider?.nombres.capitalize}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${provider?.nombres.capitalize} podrá empezar con el servicio después de que realices el pago. Recuerda el pago no se le dará a Fedor hasta que haya terminado la tarea con éxito.",
                        style: const TextStyle(color: AppColor.txtPropuesta),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.clientDetails,
                              arguments: {
                                'mapStyle': MapStyleLoader.cachedStyle,
                                'selectedProvider': provider,
                                'clientPosition': clientPosition,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.btnOpen,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Continuar",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
