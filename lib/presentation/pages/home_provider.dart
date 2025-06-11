import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/widgets/animation_home.dart';
import 'package:serviexpress_app/presentation/widgets/card_desing.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/profile_screen.dart';
import 'package:serviexpress_app/presentation/widgets/provider_details.dart';

class HomeProvider extends ConsumerStatefulWidget {
  const HomeProvider({super.key});

  @override
  ConsumerState<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends ConsumerState<HomeProvider>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final List<Widget Function()> _screens;
  late final StreamSubscription<RemoteMessage> _notificationSubscription;
  List<FCMMessage> notifications = [];
  final Map<String, ServiceComplete> _services = {};
  ServiceComplete? service;

  AppLifecycleState? _appLifecycleState;

  bool isProvider = true;

  double _buttonOpacity = 1.0;

  bool _state = true;

  bool get isAppInForeground =>
      _appLifecycleState == null ||
      _appLifecycleState == AppLifecycleState.resumed;

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
  void initState() {
    super.initState();
    _screens = [
      () => _buildHomeProvider(),
      () => const Center(
        child: Text("Conversar", style: TextStyle(fontSize: 25)),
      ),
      () => const ProfileScreen(isProvider: true),
    ];
    _setupToken();
    _setupLocation();
    _notificationSubscription = NotificationManager().notificationStream.listen(
      (RemoteMessage message) async {
        final fcmMessage = FCMMessage.fromRemoteMessage(message);
        service = await ServiceRepository.instance.getService(
          fcmMessage.idServicio,
        );

        bool exists = notifications.any(
          (notification) => notification.idServicio == fcmMessage.idServicio,
        );
        if (!exists) {
          setState(() {
            _services[fcmMessage.idServicio] = service!;
            notifications.add(fcmMessage);
          });

          if (isAppInForeground) {
            NotificationManager().showLocalNotification(
              title: fcmMessage.title ?? 'Notificación',
              body: fcmMessage.body ?? 'Tienes un nuevo mensaje.',
            );
          }
        }
      },
    );

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  void _setupLocation() async {
    await LocationMapsService().initialize();
  }

  Future<String> _getUserId(String senderId) async {
    final username = await UserRepository.instance.getUserName(senderId);
    return username;
  }

  Widget _buildHomeProvider() {
    return Stack(
      children: [
        const AnimationProvider(),
        if (notifications.isNotEmpty)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                  } else if (notification is ScrollEndNotification) {}
                  return true;
                },
                child: SizedBox(
                  //height: MediaQuery.of(context).size.height * 0.60,
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final cliente = notifications[index];
                      final serviceForCliente = _services[cliente.idServicio]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Dismissible(
                          key: Key(cliente.idServicio + index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            final userName = await _getUserId(cliente.senderId);

                            setState(() {
                              notifications.removeAt(index);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "La solicitud de $userName fue eliminada",
                                ),
                              ),
                            );
                          },
                          background: Container(
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ProviderDetails(
                                        service: serviceForCliente,
                                        mapStyle: MapStyleLoader.cachedStyle,
                                      ),
                                  transitionsBuilder: _transition,
                                  transitionDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                ),
                              );
                            },
                            child: CardDesing(service: service!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AnimatedOpacity(
          opacity: _buttonOpacity,
          duration: const Duration(milliseconds: 200),
          child:
              _buttonOpacity == 0
                  ? null
                  : Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColor.bgMsgUser,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/menu.svg',
                                width: 13,
                                height: 13,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _state ? AppColor.bgSwitch : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _state ? "Disponible" : "No Disponible",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _state ? Colors.white : Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                activeColor: Colors.white,
                activeTrackColor: AppColor.bgSwitch,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
                value: _state,
                onChanged: (value) {
                  setState(() {
                    _state = value;
                  });
                },
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: const BoxDecoration(
              color: AppColor.bgMsgUser,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                "assets/icons/ic_gochat.svg",
                color: Colors.white,
                width: 18,
                height: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
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
                      color: Colors.white,
                    ),
                    title: const Text("Solicitar servicio"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      "assets/icons/ic_historial.svg",
                      color: Colors.white,
                    ),
                    title: const Text("Historial de actividad"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      "assets/icons/ic_historial.svg",
                      color: Colors.white,
                    ),
                    title: Text(
                      isProvider ? "Cambiar a Cliente" : "Cambiar a Trabajador",
                    ),
                    onTap: () async {
                      final mapStyle = await MapStyleLoader.loadStyle();
                      Navigator.pop(context);
                      if (isProvider) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                          arguments: mapStyle,
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
                      color: Colors.white,
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
                color: Colors.white,
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
      body: _screens[_selectedIndex](),
    );
  }

  // Widget _buildBottomNavigationBar() {
  //   return Theme(
  //     data: Theme.of(context).copyWith(
  //       splashColor: Colors.transparent,
  //       highlightColor: Colors.transparent,
  //     ),
  //     child: BottomNavigationBar(
  //       backgroundColor: AppColor.bgBtnNav,
  //       items: <BottomNavigationBarItem>[
  //         BottomNavigationBarItem(
  //           icon: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: SvgPicture.asset(
  //               "assets/icons/ic_home.svg",
  //               colorFilter: ColorFilter.mode(
  //                 _selectedIndex == 0 ? AppColor.dotColor : AppColor.bgItmNav,
  //                 BlendMode.srcIn,
  //               ),
  //             ),
  //           ),
  //           label: "Home",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: SvgPicture.asset(
  //               "assets/icons/ic_chat.svg",
  //               colorFilter: ColorFilter.mode(
  //                 _selectedIndex == 1 ? AppColor.dotColor : AppColor.bgItmNav,
  //                 BlendMode.srcIn,
  //               ),
  //             ),
  //           ),
  //           label: "Conversar",
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: SvgPicture.asset(
  //               "assets/icons/ic_person.svg",
  //               colorFilter: ColorFilter.mode(
  //                 _selectedIndex == 2 ? AppColor.dotColor : AppColor.bgItmNav,
  //                 BlendMode.srcIn,
  //               ),
  //             ),
  //           ),
  //           label: "Mi Perfil",
  //         ),
  //       ],
  //       currentIndex: _selectedIndex,
  //       selectedItemColor: AppColor.dotColor,
  //       unselectedItemColor: AppColor.bgItmNav,
  //       selectedFontSize: 12,
  //       unselectedFontSize: 12,
  //       enableFeedback: true,
  //       elevation: 15,
  //       onTap: (index) {
  //         setState(() {
  //           _selectedIndex = index;
  //         });
  //       },
  //     ),
  //   );
  // }

  Widget _transition(context, animation, secondaryAnimation, child) {
    const begin = Offset(0.0, 0.1);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    final opacityTween = Tween<double>(begin: 0.0, end: 1.0);

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(opacityTween),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
