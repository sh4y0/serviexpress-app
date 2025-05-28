import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class HomeProvider extends StatefulWidget {
  const HomeProvider({super.key});

  @override
  State<HomeProvider> createState() => _HomeProviderState();
}

class _HomeProviderState extends State<HomeProvider> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> drivers = [
    {"name": "Carlos", "description": "Arregla una lavadora", "distance": "A 30 min de ti"},
    {"name": "Ana", "description": "Arregla una lavadora", "distance": "2.7 km"},
    {"name": "Luis", "description": "Arregla una lavadora", "distance": "4.1 km"},
    {"name": "Luis", "description": "Arregla una lavadora", "distance": "4.1 km"},
  ];
  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 15;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: IconButton(
              onPressed: () {},
              icon: const Badge(
                smallSize: 13,
                child: Icon(
                  Icons.notifications_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              style: IconButton.styleFrom(backgroundColor: AppColor.bgMsgUser),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: topPadding,
            left: 16,
            right: 16,
            child: Column(
              children:
                  drivers.map((driver) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.bgAll,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver["name"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    driver["description"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    driver["distance"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              
                              const Icon(
                                Icons.home_repair_service,
                                color: Colors.lightGreenAccent,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
}
