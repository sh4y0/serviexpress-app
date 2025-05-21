import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.bgOnBoar,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == 2);
                },
                children: const [
                  Onboardingpage(
                    image: "assets/icons/onborning_one.svg",
                    title: "¡Tu hogar en buenas manos!",
                    description:
                        "Solicita servicios de limpieza, pintura y más, desde tu celular y sin complicaciones.",
                  ),
                  Onboardingpage(
                    image: "assets/icons/onborning_two.svg",
                    title: "Profesionales verificados",
                    description:
                        "Elige a expertos calificados, revisa opiniones y programa el servicio según tu horario.",
                  ),
                  Onboardingpage(
                    image: "assets/icons/onborning_three.svg",
                    title: "Paga con garantía",
                    description:
                        "Tu dinero está protegido hasta que el servicio esté completado. Sin sorpresas, sin riesgos.",
                  ),
                ],
              ),
            ),

            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColor.activeDot,
                dotColor: AppColor.dotColor,
                dotHeight: 8,
                dotWidth: 10,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
              child:
                  isLastPage
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.toNamed("/signUp");
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColor.bgAll),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Registrarse",
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
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed("/login");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.bgAll,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _controller.jumpToPage(2),
                            child: const Text(
                              "Skip",
                              style: TextStyle(
                                color: AppColor.bgAll,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.bgAll,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(18),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class Onboardingpage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  const Onboardingpage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Center(
            child: SvgPicture.asset(
              image,
              height: MediaQuery.of(context).size.height * 0.60,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: AppColor.txtDesc),
          ),
          const Spacer(flex: 1,)
        ],
      ),
    );
  }
}
