import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class ProfileScreen extends StatefulWidget {
  final bool isProvider;
  const ProfileScreen({super.key, required this.isProvider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColor.bgMsgClient,
            title: const Text("Cerrar Sesion"),
            content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  AuthRepository.instance.logout();
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil("/login", (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sesión cerrada")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Cerrar Sesion",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      {"icon": Icons.edit, "title": "Editar Perfil"},
      {"icon": Icons.notifications, "title": "Notificaciones"},
      {"icon": Icons.settings, "title": "Preferencias"},
      widget.isProvider
          ? {
            "icon": Icons.published_with_changes,
            "title": "Cambiar a Cliente",
            "route": AppRoutes.home,
          }
          : {
            "icon": Icons.published_with_changes,
            "title": "Cambiar a Trabajador",
            "route": AppRoutes.homeProvider,
          },
      {"icon": Icons.help_outline, "title": "Ayuda"},
    ];
    return Scaffold(
      backgroundColor: AppColor.bgCard,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Mi Perfil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (index < options.length) {
                    final option = options[index];
                    return ListTile(
                      leading: Icon(option["icon"] as IconData),
                      title: Text(option["title"] as String),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final route = option["route"];
                        final mapStyle = await MapStyleLoader.loadStyle();
                        if (route != null) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            route as String,
                            (route) => false,
                            arguments: mapStyle,
                          );
                        }
                      },
                    );
                  } else {
                    return ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Cerrar sesión",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _logout(context),
                    );
                  }
                },
                separatorBuilder:
                    (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                itemCount: options.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
