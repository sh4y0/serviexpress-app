import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/pages/home_page_content.dart';
import 'package:serviexpress_app/presentation/viewmodels/skeleton_home.dart';
import 'package:serviexpress_app/presentation/widgets/profile_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  final String mapStyle;
  const HomePage({super.key, required this.mapStyle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _mapLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupToken();
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
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
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSkeletonBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(22, 26, 80, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromRGBO(200, 200, 200, 0.3),
                  highlightColor: const Color.fromRGBO(255, 255, 255, 0.6),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(58, 68, 157, 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: const Color.fromRGBO(200, 200, 200, 0.3),
                  highlightColor: const Color.fromRGBO(255, 255, 255, 0.6),
                  child: Container(
                    width: _getSkeletonTextWidth(index),
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(58, 68, 157, 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  double _getSkeletonTextWidth(int index) {
    switch (index) {
      case 0:
        return 40.0;
      case 1:
        return 60.0;
      case 2:
        return 55.0;
      default:
        return 50.0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Stack(
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
          ),
          if (!_mapLoaded)
            const Positioned.fill(
              child: SkeletonHome(),
            ),
        ],
      ),
      const Center(
        child: Text("Conversar", style: TextStyle(fontSize: 25)),
      ),
      const ProfileScreen(isProvider: false),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar:
          _mapLoaded
              ? _buildBottomNavigationBar()
              : _buildSkeletonBottomNavigationBar(),
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
