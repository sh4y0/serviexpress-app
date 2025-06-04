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
      backgroundColor: AppColor.bgMsgUser,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                "Perfil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 50,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.btnOpen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            "assets/images/profile_default.png",
                          ),
                          backgroundColor: Colors.white,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.bgAll,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 155,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Jeffer G".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (index < options.length) {
                    final option = options[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          option["icon"] as IconData,
                          color: Colors.white,
                        ),
                        title: Text(
                          option["title"] as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),
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
                      ),
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
