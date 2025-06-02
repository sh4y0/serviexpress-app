import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/widgets/cardDesing.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';
import 'package:serviexpress_app/presentation/widgets/provider_details.dart';

class HomeProvider extends StatefulWidget {
  const HomeProvider({super.key});

  @override
  State<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends State<HomeProvider> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> clientes = [
    {
      "name": "Carlos Enrique Casemiro",
      "description": "Arregla una lavadora que no enciende",
      "distance": "A 30 min de ti",
      "images": [
        "assets/images/img_services.png",
        "assets/images/img_services.png",
        "assets/images/img_services.png",
        "assets/images/img_services.png",
      ],
    },
    {
      "name": "Ana Lucia Mendez Hugarte",
      "description": "Limpiar un locar de 300m",
      "distance": "2.7 km",
      "images": ["assets/images/img_services.png"],
    },
    {
      "name": "Luis Alfredo Benites ",
      "description":
          "Instalar ventanas en una habitacion y en la sala de unos 250 metros aproximadamente",
      "distance": "4.1 km",
      "images": ["assets/images/img_services.png"],
    },
    {
      "name": "Mario Gimenez Mendez",
      "description": "Reparar un refrigerador que no congela",
      "distance": "4.1 km",
      "images": ["assets/images/img_services.png"],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColor.backgroudGradient,
            ),
          ),
          if (clientes.isNotEmpty)
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
                      itemCount: clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = clientes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Dismissible(
                            key: Key(cliente["name"] + index.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              setState(() {
                                clientes.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${cliente["name"]} fue eliminado",
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
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => ProviderDetails(cliente: cliente, mapStyle: MapStyleLoader.cachedStyle),
                                    transitionsBuilder: _transition,
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );
                              },
                              child: CardDesing(cliente: cliente),
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
}
