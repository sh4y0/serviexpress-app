import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboarndingScreen extends StatefulWidget {
  const OnboarndingScreen({super.key});

  @override
  State<OnboarndingScreen> createState() => _OnboarndingScreenState();
}

class _OnboarndingScreenState extends State<OnboarndingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        backgroundColor: AppColor.bgOnBoar,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => isLastPage = index == 2);
                  },
                  children: const [
                    _OnboardContent(
                      image: "assets/icons/onborning_one.svg",
                      title: "¡Tu hogar en buenas manos!",
                      description:
                          "Solicita servicios de limpieza, pintura y más, desde tu celular y sin complicaciones.",
                    ),
                    _OnboardContent(
                      image: "assets/icons/onborning_two.svg",
                      title: "Profesionales verificados",
                      description:
                          "Elige a expertos calificados, revisa opiniones y programa el servicio según tu horario.",
                    ),
                    _OnboardContent(
                      image: "assets/icons/onborning_three.svg",
                      title: "Paga con garantía",
                      description:
                          "Tu dinero está protegido hasta que el servicio esté completado. Sin sorpresas, sin riesgos.",
                    ),
                  ],
                ),
              ),
      
              Expanded(
                flex: 1,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColor.activeDot,
                      dotColor: AppColor.dotColor,
                      dotHeight: 8,
                      dotWidth: 10,
                    ),
                  ),
                ),
              ),
      
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      isLastPage
                          ? _buildFinalButtons()
                          : _buildNavigationButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalButtons() {
    return Row(
      children: [
        Expanded(
          child: MaterialButton(
            onPressed: () {
              Get.toNamed("/signUp");
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColor.bgAll),
            ),
            height: 45,
            child: const Text(
              "Empleador",
              style: TextStyle(
                color: AppColor.bgAll,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: MaterialButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            color: AppColor.bgAll,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            height: 45,
            child: const Text(
              "Cliente",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MaterialButton(
          onPressed: () => _controller.jumpToPage(2),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: const Text(
            "Skip",
            style: TextStyle(color: AppColor.bgAll, fontSize: 16),
          ),
        ),

        MaterialButton(
          onPressed: () {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          color: AppColor.bgAll,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minWidth: 56,
          height: 56,
          padding: EdgeInsets.zero,
          child: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ],
    );
  }
}

class _OnboardContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const _OnboardContent({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Expanded(
            flex: 5,
            child: Center(child: SvgPicture.asset(image, fit: BoxFit.contain)),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(description, style: const TextStyle(color: AppColor.txtDesc)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
