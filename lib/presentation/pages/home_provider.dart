import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/data/models/fmc_message.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/viewmodels/service_complete_view_model.dart';
import 'package:serviexpress_app/presentation/widgets/cardDesing.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/provider_details.dart';

class HomeProvider extends ConsumerStatefulWidget {
  const HomeProvider({super.key});

  @override
  ConsumerState<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends ConsumerState<HomeProvider>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final StreamSubscription<RemoteMessage> _notificationSubscription;
  List<FCMMessage> notifications = [];
  Service? _service;

  AppLifecycleState? _appLifecycleState;

  bool get isAppInForeground =>
      _appLifecycleState == null ||
      _appLifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationSubscription = NotificationManager().notificationStream
          .listen((RemoteMessage message) async {
            final fcmMessage = FCMMessage.fromRemoteMessage(message);

            ref
                .read(serviceCompleteViewModelProvider.notifier)
                .getService(fcmMessage.idServicio);

            bool exists = notifications.any(
              (notification) =>
                  notification.idServicio == fcmMessage.idServicio,
            );
            if (!exists) {
              setState(() {
                notifications.add(fcmMessage);
              });

              if (isAppInForeground) {
                NotificationManager().showLocalNotification(
                  title: fcmMessage.title ?? 'Notificación',
                  body: fcmMessage.body ?? 'Tienes un nuevo mensaje.',
                );
              }
            }
          });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
  }

  void _listenToServiceViewModel() {
    ref.listen<ResultState>(serviceCompleteViewModelProvider, (_, next) async {
      if (next is Success<Service>) {
        setState(() {
          _service = next.data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToServiceViewModel();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColor.backgroudGradient,
            ),
          ),
          if (notifications.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Dismissible(
                            key: Key(cliente.idServicio + index.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              setState(() {
                                notifications.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${cliente.idServicio} fue eliminado",
                                  ),
                                  duration: const Duration(seconds: 1),
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
                                if (_service != null) {
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ProviderDetails(
                                          service: _service!,
                                          mapStyle: MapStyleLoader.cachedStyle,
                                        ),
                                    transitionsBuilder: _transition,
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );
                              },
                              child:
                                  _service != null
                                      ? CardDesing(service: _service!)
                                      : const SizedBox(
                                        child: Text("No hay servicio causa"),
                                      ),
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
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColor.bgBtnNav,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/icons/ic_home.svg",
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 0 ? AppColor.dotColor : AppColor.bgItmNav,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/icons/ic_chat.svg",
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 1 ? AppColor.dotColor : AppColor.bgItmNav,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: "Conversar",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/icons/ic_person.svg",
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 2 ? AppColor.dotColor : AppColor.bgItmNav,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: "Mi Perfil",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColor.dotColor,
          unselectedItemColor: AppColor.bgItmNav,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          enableFeedback: true,
          elevation: 15,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
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
    super.dispose();
  }
}
