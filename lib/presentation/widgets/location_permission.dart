import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/auth/auth_result.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class LocationPermission extends StatefulWidget {
  final String role;
  const LocationPermission({super.key, required this.role});

  @override
  State<LocationPermission> createState() => _LocationPermissionState();
}

class _LocationPermissionState extends State<LocationPermission> {
  late EnhancedLocationService _locationService;
  AuthResult? authResult;

  @override
  void initState() {
    super.initState();
    _locationService = EnhancedLocationService();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.height < 600;

    return Scaffold(
      backgroundColor: AppColor.bgOnBoar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: isSmallDevice ? 10 : 20),

              Expanded(
                flex: 4,
                child: SvgPicture.asset(
                  "assets/icons/location_permission2.svg",
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Autoriza el uso de tu ubicación",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Tu ubicación es clave para recibir un servicio preciso y sin demoras",
                  style: TextStyle(color: AppColor.txtDesc, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    bool permissionSuccesfull =
                        await _locationService.requestLocationPermission();
                    if (permissionSuccesfull) {
                      final String targetRoute =
                          (widget.role == "Trabajador")
                              ? AppRoutes.homeProvider
                              : AppRoutes.home;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        targetRoute,
                        (route) => false,
                        arguments: MapStyleLoader.cachedStyle,
                      );
                    }
                  },
                  child: const Text(
                    "Activar servicios de ubicación",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                      arguments: MapStyleLoader.cachedStyle,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  child: const Text(
                    "Saltar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
