import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class AnimationProvider extends StatefulWidget {
  const AnimationProvider({super.key});

  @override
  State<AnimationProvider> createState() => _AnimationProviderState();
}

class _AnimationProviderState extends State<AnimationProvider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildAnimatedCircle(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        double scale = (_controller.value + delay) % 1;
        double opacity = 1.0 - scale;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.1 + scale * 3,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.btnColor.withOpacity(0.4),
                    AppColor.btnColor.withOpacity(0.5),
                  ],
                  stops: const [0.7, 1.0],
                ),
                border: Border.all(color: AppColor.btnColor),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      body: Center(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Stack(
                alignment: Alignment.center,
                children: [
                  buildAnimatedCircle(0.0),
                  buildAnimatedCircle(0.33),
                  buildAnimatedCircle(0.66),
                  SvgPicture.asset("assets/icons/ic_location.svg"),
                ],
              ),
              const SizedBox(height: 80),

              const Text(
                "Buscando solicitudes cerca",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
