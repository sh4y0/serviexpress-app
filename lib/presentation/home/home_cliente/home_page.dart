import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/home/home_cliente/home_page_content.dart';
import 'package:serviexpress_app/presentation/widgets/common/app_drawer.dart';
import 'package:serviexpress_app/presentation/widgets/common/skeleton_home.dart';

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
    UserPreferences.activeServiceId.value = null;
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
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
            onLogout: () => Alerts.instance.showLogoutAlert(context),
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
