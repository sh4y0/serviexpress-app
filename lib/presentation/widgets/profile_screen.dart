import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      {
        "iconPath": "assets/icons/ic_privacidad.svg",
        "title": "Privacidad",
        "trailing": "",
      },
      {
        "iconPath": "assets/icons/ic_notify.svg",
        "title": "Notificaciones",
        "trailing": "ON",
      },
      {
        "iconPath": "assets/icons/ic_idioma.svg",
        "title": "Idioma",
        "trailing": "English",
      },
    ];

    final options2 = [
      {
        "iconPath": "assets/icons/ic_verification_mov.svg",
        "title": "Verificacion móvil",
      },
      {
        "iconPath": "assets/icons/ic_historial.svg",
        "title": "Historial de actividad",
        //"route": AppRoutes.cambioRol,
      },
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
    ];
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 70,
                              backgroundImage: AssetImage(
                                "assets/images/avatar.png",
                              ),
                              backgroundColor: Colors.white,
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(
                                    "assets/icons/ic_edit.svg",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Jeffer G".toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "youremail@domain.com",
                            style: TextStyle(
                              color: AppColor.txtEmailPhone,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "|",
                            style: TextStyle(
                              color: AppColor.txtEmailPhone,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "+01 234 567 89",
                            style: TextStyle(
                              color: AppColor.txtEmailPhone,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < options.length) {
                            final option = options[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.grey.withOpacity(0.3),
                                highlightColor: Colors.grey.withOpacity(0.18),
                                onTap: () async {
                                  final route = option["route"];
                                  if (route != null) {
                                    if (route == AppRoutes.home) {
                                      final mapStyle =
                                          await MapStyleLoader.loadStyle();
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        route,
                                        (route) => false,
                                        arguments: mapStyle,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        route,
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                child: ListTile(
                                  leading: SvgPicture.asset(
                                    option["iconPath"] as String,
                                    width: 24,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    option["title"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    option["trailing"] as String,
                                    style: const TextStyle(
                                      color: AppColor.txtTrailing,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        separatorBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        itemCount: options.length,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < options2.length) {
                            final option = options2[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.grey.withOpacity(0.3),
                                highlightColor: Colors.grey.withOpacity(0.18),
                                onTap: () async {
                                  if (option["route"] != null) {
                                    if (option["route"] == AppRoutes.home) {
                                      final mapStyle =
                                          await MapStyleLoader.loadStyle();
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        option["route"] as String,
                                        (route) => false,
                                        arguments: mapStyle,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        option["route"] as String,
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                child: ListTile(
                                  leading:
                                      option["iconPath"] != null
                                          ? SvgPicture.asset(
                                            option["iconPath"] as String,
                                            width: 24,
                                            height: 24,
                                            color: Colors.white,
                                          )
                                          : Icon(
                                            option["icon"] as IconData,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  title: Text(
                                    option["title"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        separatorBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        itemCount: options2.length,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey.withOpacity(0.3),
                              highlightColor: Colors.grey.withOpacity(0.18),
                              onTap: () {},
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  "assets/icons/ic_delete_account.svg",
                                ),
                                title: const Text(
                                  "Eliminar cuenta",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey.withOpacity(0.3),
                              highlightColor: Colors.grey.withOpacity(0.18),
                              onTap: () => _logout(context),
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  "assets/icons/ic_exit.svg",
                                ),
                                title: const Text(
                                  "Cerrar sesión",
                                  style: TextStyle(color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
