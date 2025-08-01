import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:serviexpress_app/presentation/home/home_proveedor/animation_provider.dart';
import 'package:serviexpress_app/presentation/widgets/common/app_drawer.dart';
import 'package:serviexpress_app/presentation/widgets/card_desing.dart';
import 'package:serviexpress_app/presentation/widgets/common/location_not_found_banner.dart';
import 'package:serviexpress_app/presentation/widgets/common/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/common/profile_screen.dart';
import 'package:serviexpress_app/presentation/home/home_proveedor/provider_details.dart';
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

  LocationBannerState _determineBannerState(
    EnhancedLocationService locationState,
  ) {
    if (locationState.shouldShowNotFoundBanner) {
      return LocationBannerState.notFound;
    }
    if (locationState.shouldShowSearchingBanner) {
      return LocationBannerState.searching;
    }
    return LocationBannerState.hidden;
  }

  bool _isLocationAvailable(EnhancedLocationService locationService) {
    return locationService.isPermissionGranted &&
        locationService.isServiceEnabled &&
        locationService.hasLocation;
  }

  Widget _buildHomeProvider() {
    final locationService = ref.watch(locationNotifierProvider);
    final isLocationAvailable = _isLocationAvailable(locationService);

    final currentPosition =
        locationService.currentPosition != null
            ? LatLng(
              locationService.currentPosition!.latitude,
              locationService.currentPosition!.longitude,
            )
            : null;

    return Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _state,
          builder: (context, stateValue, _) {
            return AnimationProvider(
              showAnimation: stateValue && isLocationAvailable,
              hasLocation: isLocationAvailable,
            );
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
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);
    final bannerState = _determineBannerState(locationState);
    final isLocationAvailable = _isLocationAvailable(locationState);

    UserRepository.instance.toggleUserAvailability(isLocationAvailable);
    _state.value = isLocationAvailable;

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
                      color:
                          (stateValue && isLocationAvailable)
                              ? AppColor.bgSwitch
                              : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: _state,
                builder: (context, stateValue, _) {
                  String statusText;
                  Color statusColor;

                  if (!isLocationAvailable) {
                    statusText = "Sin Ubicación";
                    statusColor = Colors.grey[400]!;
                  } else if (stateValue) {
                    statusText = "Disponible";
                    statusColor = Colors.white;
                  } else {
                    statusText = "No Disponible";
                    statusColor = Colors.grey[300]!;
                  }

                  return Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
                    value: stateValue && isLocationAvailable,
                    onChanged:
                        isLocationAvailable
                            ? (value) async {
                              await UserRepository.instance
                                  .toggleUserAvailability(value);
                              _state.value = value;
                            }
                            : null,
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
      drawer: ValueListenableBuilder<UserModel?>(
        valueListenable: user,
        builder: (context, userValue, _) {
          return AppDrawer(
            user: userValue,
            isProvider: true,
            onLogout: () => Alerts.instance.showLogoutAlert(context),
            onUserRefresh: _getUserById,
            isProviderDrawer: true,
          );
        },
      ),
      body: LocationBannerController(
        bannerState: bannerState,

        onLocationPermissionTap: () {
          if (locationState.currentState == LocationState.serviceDisabled) {
            locationNotifier.requestLocationService();
          } else if (locationState.currentState ==
              LocationState.permissionDenied) {
            locationNotifier.requestLocationPermission();
          }
        },
        onBannerDismiss: () => LocationBannerState.hidden,
        onSearchCancel: () => LocationBannerState.hidden,

        child: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, idx, _) => _screens[idx](),
        ),
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
