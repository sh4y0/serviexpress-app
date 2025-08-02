import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';

class CambioRol extends StatefulWidget {
  const CambioRol({super.key});

  @override
  State<CambioRol> createState() => _CambioRolState();
}

class _CambioRolState extends State<CambioRol> {
  String? currentRole;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadRole();
    }
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
    Navigator.pushNamed(context, AppRoutes.login, arguments: {"login": false});
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
      backgroundColor: AppColor.bgVerification,
      appBar: AppBar(
        backgroundColor: AppColor.bgVerification,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Center(
                  child: SvgPicture.asset("assets/icons/works.svg", width: 300),
                ),
                const SizedBox(height: 30),
                const Text(
                  "¿Deseas generar ingresos realizando servicios?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "En ServiExpress podrás ofrecer tus servicios a nuestros clientes y ofrecer tarifas por ello.",
                  style: TextStyle(color: AppColor.txtPropuesta, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              children: [
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
                            color: Colors.white,
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
                          Navigator.pushNamed(
                            context,
                            AppRoutes.login,
                            arguments: {"login": true},
                          );
                        },
                        child: const Text(
                          "Tengo una cuenta",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
