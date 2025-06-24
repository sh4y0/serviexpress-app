import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/messaging/service/location_provider.dart';
import 'package:serviexpress_app/presentation/widgets/animation_provider.dart';
import 'package:serviexpress_app/presentation/widgets/card_desing.dart';
import 'package:serviexpress_app/presentation/widgets/location_not_found_banner.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/profile_screen.dart';
import 'package:serviexpress_app/presentation/widgets/provider_details.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';

class HomeProvider extends ConsumerStatefulWidget {
  const HomeProvider({super.key});

  @override
  ConsumerState<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends ConsumerState<HomeProvider>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  late final List<Widget Function()> _screens;
  late final StreamSubscription<RemoteMessage> _notificationSubscription;
  final ValueNotifier<List<FCMMessage>> notifications =
      ValueNotifier<List<FCMMessage>>([]);
  final Map<String, ServiceComplete> _services = {};
  ServiceComplete? service;

  final ValueNotifier<AppLifecycleState?> _appLifecycleState =
      ValueNotifier<AppLifecycleState?>(null);

  bool isProvider = true;

  final double _buttonOpacity = 1.0;

  final ValueNotifier<bool> _state = ValueNotifier<bool>(true);

  final ValueNotifier<UserModel?> user = ValueNotifier<UserModel?>(null);
  final Set<String> _processedServiceIds = {};

  @override
  void initState() {
    super.initState();
    _getUserById();
    _setStateSwitch();
    _screens = [
      () => _buildHomeProvider(),
      () => const Center(
        child: Text("Conversar", style: TextStyle(fontSize: 25)),
      ),
      () => const ProfileScreen(),
    ];
    _setupToken();
    _notificationSubscription = NotificationManager().notificationStream.listen(
      (RemoteMessage message) async {
        final fcmMessage = FCMMessage.fromRemoteMessage(message);

        if (_processedServiceIds.contains(fcmMessage.idServicio)) {
          return;
        }

        service = await ServiceRepository.instance.getService(
          fcmMessage.idServicio,
        );

        print("ServiExpress - service: $service");
        if (service != null) {
          if (!notifications.value.any(
            (n) => n.idServicio == fcmMessage.idServicio,
          )) {
            _services[fcmMessage.idServicio] = service!;
            notifications.value = List.from(notifications.value)
              ..add(fcmMessage);
            _processedServiceIds.add(fcmMessage.idServicio);
          }
        }
      },
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState.value = state;
  }

  void _setStateSwitch() async {
    final value = await UserRepository.instance.getUserAvailability();
    _state.value = value;
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  Future<String> _getUserId(String senderId) async {
    final username = await UserRepository.instance.getUserName(senderId);
    return username;
  }

  void _getUserById() async {
    final uid = await UserPreferences.getUserId();
    if (uid == null) return;
    var userFetch = await UserRepository.instance.getCurrentUser(uid);
    if (!mounted) return;
    user.value = userFetch;
  }

  Widget _buildHomeProvider() {
    final locationService = ref.watch(locationNotifierProvider);

    final currentPosition = locationService.currentPosition != null
        ? LatLng(locationService.currentPosition!.latitude, locationService.currentPosition!.longitude)
        : null;
        
    return Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _state,
          builder: (context, stateValue, _) {
            return AnimationProvider(showAnimation: stateValue);
          },
        ),
        ValueListenableBuilder<List<FCMMessage>>(
          valueListenable: notifications,
          builder: (context, notifList, _) {
            if (notifList.isEmpty) return const SizedBox.shrink();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) => true,
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: notifList.length,
                      itemBuilder: (context, index) {
                        final cliente = notifList[index];
                        final serviceForCliente =
                            _services[cliente.idServicio]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Dismissible(
                            key: Key(cliente.idServicio + index.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              final userName = await _getUserId(
                                cliente.senderId,
                              );
                              final id = notifList[index].idServicio;

                              notifications.value = List.from(
                                notifications.value,
                              )..removeAt(index);
                              _processedServiceIds.remove(id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColor.bgMsgUser,
                                  content: Text(
                                    "La solicitud de $userName fue eliminada",
                                    style: const TextStyle(color: Colors.white),
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
                            child: CardDesing(
                              service: serviceForCliente,
                              onViewDetails: () {
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
                                          position: currentPosition,
                                          mapStyle: MapStyleLoader.cachedStyle,
                                        ),
                                    transitionsBuilder: _transition,
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
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
              ValueListenableBuilder<bool>(
                valueListenable: _state,
                builder: (context, stateValue, _) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: stateValue ? AppColor.bgSwitch : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: _state,
                builder: (context, stateValue, _) {
                  return Text(
                    stateValue ? "Disponible" : "No Disponible",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: stateValue ? Colors.white : Colors.grey[300],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: _state,
                builder: (context, stateValue, _) {
                  return Switch(
                    activeColor: Colors.white,
                    activeTrackColor: AppColor.bgSwitch,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                    value: stateValue,
                    onChanged: (value) async {
                      await UserRepository.instance.toggleUserAvailability(
                        value,
                      );
                      _state.value = value;
                    },
                  );
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
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
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
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: user,
          builder: (context, user, _) {
            return Column(
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
                                  width: 60,
                                  height: 60,
                                  child:
                                      user.imagenUrl!.isNotEmpty
                                          ? FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/avatar.png",
                                            image: user.imagenUrl!,
                                            fit: BoxFit.cover,
                                            imageErrorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                "assets/images/avatar.png",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                          : Image.asset(
                                            "assets/images/avatar.png",
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nombreCompleto,
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
                                          user.calificacion.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        // const Text(
                                        //   "(120+ review)",
                                        //   style: TextStyle(
                                        //     color: Colors.white60,
                                        //     fontSize: 14,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      user.especialidad!,
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
                                          builder:
                                              (context) =>
                                                  const ProfileScreen(),
                                        ),
                                      )
                                      .then((_) {
                                        _getUserById();
                                      });
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
                        leading: const Image(
                          image: AssetImage("assets/icons/ic_change.png"),
                          color: Colors.white,
                          width: 25,
                          height: 25,
                        ),
                        title: Text(
                          isProvider
                              ? "Cambiar a Cliente"
                              : "Cambiar a Trabajador",
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
                    ],
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    "assets/icons/ic_exit.svg",
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Alerts.instance.showLogoutAlert(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, idx, _) => _screens[idx](),
      ),
    );
  }

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
    _selectedIndex.dispose();
    notifications.dispose();
    _state.dispose();
    _appLifecycleState.dispose();
    super.dispose();
  }
}
