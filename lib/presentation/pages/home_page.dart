import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/pages/home_page_content.dart';
import 'package:serviexpress_app/presentation/viewmodels/skeleton_home.dart';
import 'package:serviexpress_app/presentation/widgets/profile_screen.dart';

class HomePage extends StatefulWidget {
  final String mapStyle;
  const HomePage({super.key, required this.mapStyle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _mapLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProvider = false;

  @override
  void initState() {
    super.initState();
    _setupToken();
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

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
                    const SnackBar(
                      content: Text(
                        "Sesión cerrada",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColor.bgMsgClient,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Cerrar Sesion",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: AppColor.bgCard,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1B1B2E),
                          ),
                          child: Image.asset(
                            "assets/images/profile_default.png",
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Fedor Kiryakov",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "4.9",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "(120+ review)",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Limpiador",
                                style: TextStyle(
                                  color: AppColor.textInput,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                    title: const Text("Solicitar servicio"),
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      "assets/icons/ic_historial.svg",
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(
                      isProvider ? "Cambiar a Cliente" : "Cambiar a Trabajador",
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (isProvider) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                          arguments: widget.mapStyle,
                        );
                      } else {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.homeProvider,
                          (route) => false,
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      "assets/icons/ic_person.svg",
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: const Text("Perfil"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const ProfileScreen(isProvider: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                "assets/icons/ic_exit.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text("Cerrar Sesión"),
              onTap: () {
                _logout(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          HomePageContent(
            mapStyle: widget.mapStyle,
            onMapLoaded: (isLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _mapLoaded != isLoaded) {
                  setState(() {
                    _mapLoaded = isLoaded;
                  });
                }
              });
            },
            onMenuPressed: _openDrawer,
          ),
          if (!_mapLoaded) const Positioned.fill(child: SkeletonHome()),
        ],
      ),
    );
  }
}

class MapMovementController {
  final Set<String> _programmaticOperations = {};

  void startProgrammaticMove(String operationId) {
    _programmaticOperations.add(operationId);
  }

  void endProgrammaticMove(String operationId) {
    _programmaticOperations.remove(operationId);
  }

  bool get isProgrammaticMove => _programmaticOperations.isNotEmpty;

  void dispose() {
    _programmaticOperations.clear();
  }
}
