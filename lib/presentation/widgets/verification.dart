import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/verifications_string.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class Verification extends StatelessWidget {
  const Verification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              ClipPath(
                clipper: TopCurvedClipper(),
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.fromLTRB(14, 80, 14, 80),
                  decoration: BoxDecoration(
                    color: AppColor.bgCard,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        VerificationsString.verified,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        VerificationsString.verificationSuccessMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColor.bgCircle,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    "assets/icons/ic_verification.svg",
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.homeProvider,
                    arguments: MapStyleLoader.cachedStyle,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.btnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  VerificationsString.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double curveHeight = 50.0;
    const double curveWidth = 115.0;

    final path = Path();
    path.moveTo(0, curveHeight);

    path.lineTo((size.width - curveWidth) / 2, curveHeight);
    path.arcToPoint(
      Offset((size.width + curveWidth) / 2, curveHeight),
      radius: const Radius.circular(curveWidth / 2),
      clockwise: false,
    );
    path.lineTo(size.width, curveHeight);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
