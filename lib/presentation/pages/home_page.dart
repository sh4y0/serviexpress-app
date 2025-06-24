import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/pages/home_page_content.dart';
import 'package:serviexpress_app/presentation/widgets/app_drawer.dart';
import 'package:serviexpress_app/presentation/widgets/skeleton_home.dart';

class HomePage extends StatefulWidget {
  final String mapStyle;
  const HomePage({super.key, required this.mapStyle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProvider = false;

  final ValueNotifier<UserModel?> user = ValueNotifier<UserModel?>(null);
  final ValueNotifier<bool> _mapLoaded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _setupToken();
    _getUserById();
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

  void _getUserById() async {
    final uid = await UserPreferences.getUserId();
    if (uid == null) return;
    var userFetch = await UserRepository.instance.getCurrentUser(uid);
    if (!mounted) return;
    user.value = userFetch;
  }

  @override
  void dispose() {
    user.dispose();
    _mapLoaded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ValueListenableBuilder<UserModel?>(
        valueListenable: user,
        builder: (context, userValue, _) {
          return AppDrawer(
            user: userValue,
            isProvider: false,
            onLogout: () => _logout(context),
            onUserRefresh: _getUserById,
            isProviderDrawer: false,
          );
        },
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
                if (mounted && _mapLoaded.value != isLoaded) {
                  _mapLoaded.value = isLoaded;
                }
              });
            },
            onMenuPressed: _openDrawer,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _mapLoaded,
            builder: (context, loaded, _) {
              if (loaded) return const SizedBox.shrink();
              return const Positioned.fill(child: SkeletonHome());
            },
          ),
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
