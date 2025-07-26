import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/widgets/common/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final UserModel? user;
  final bool isProvider;
  final VoidCallback onLogout;
  final VoidCallback onUserRefresh;
  final bool isProviderDrawer;
  const AppDrawer({
    super.key,
    required this.user,
    required this.isProvider,
    required this.onLogout,
    required this.onUserRefresh,
    required this.isProviderDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.bgCard,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child:
                                user!.imagenUrl!.isNotEmpty
                                    ? FadeInImage.assetNetwork(
                                      placeholder: "assets/images/avatar.png",
                                      image: user!.imagenUrl!,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (_, __, ___) => Image.asset(
                                            "assets/images/avatar.png",
                                          ),
                                    )
                                    : Image.asset("assets/images/avatar.png"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user!.nombreCompleto,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    user!.calificacion.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isProviderDrawer
                                    ? user!.especialidad ?? ""
                                    : user!.rol ?? "",
                                style: const TextStyle(
                                  color: AppColor.textInput,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                )
                                .then((_) => onUserRefresh());
                          },
                          icon: SvgPicture.asset(
                            "assets/icons/ic_edit.svg",
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  leading: SvgPicture.asset(
                    "assets/icons/ic_solicitar.svg",
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    isProvider ? "Ver Solicitudes" : "Solicitar Servicio",
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    "assets/icons/ic_historial.svg",
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text("Historial de actividad"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Image(
                    image: AssetImage("assets/icons/ic_change.png"),
                    color: Colors.white,
                    width: 25,
                    height: 25,
                  ),
                  title: Text(
                    isProvider ? "Cambiar a Cliente" : "Cambiar a Trabajador",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.cambioRol);
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              "assets/icons/ic_exit.svg",
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            title: const Text(
              "Cerrar Sesión",
              style: TextStyle(color: Colors.red),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
