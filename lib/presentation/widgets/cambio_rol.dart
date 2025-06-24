import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';

class CambioRol extends StatefulWidget {
  const CambioRol({super.key});

  @override
  State<CambioRol> createState() => _CambioRolState();
}

class _CambioRolState extends State<CambioRol> {
  String? currentRole;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await UserPreferences.getRoleName();
    setState(() {
      currentRole = role;
    });
  }

  Future<void> _cambiarRol() async {
    final nuevoRol = currentRole == "Trabajador" ? "Cliente" : "Trabajador";
    await UserPreferences.saveRoleName(nuevoRol);
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (currentRole == null) {
      return const Scaffold(
        backgroundColor: AppColor.bgCard,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final esTrabajador = currentRole == "Trabajador";
    return Scaffold(
      backgroundColor: AppColor.bgOnBoar,
      appBar: AppBar(backgroundColor: AppColor.bgOnBoar),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                "assets/icons/work.svg",
                width: 300,
                height: 450,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: currentRole != null ? _cambiarRol : null,
                    child: Text(
                      esTrabajador
                          ? "Registrarme como Cliente"
                          : "Registrarme como Trabajador",
                      style: const TextStyle(
                        color: AppColor.btnOpen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.bgBack,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      "Tengo una cuenta",
                      style: TextStyle(
                        color: AppColor.btnOpen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Divider(),
                  Text(
                    currentRole != null
                        ? "Modo $currentRole"
                        : "Cargando Rol...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
