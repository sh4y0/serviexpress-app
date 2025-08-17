import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/animation_provider_string.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/animation_provider_keys.dart';

class AnimationProvider extends StatefulWidget {
  final bool showAnimation;
  final bool hasLocation;

  const AnimationProvider({
    super.key,
    required this.showAnimation,
    required this.hasLocation,
  });

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
    );

    if (widget.showAnimation && widget.hasLocation) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimationProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation != oldWidget.showAnimation ||
        widget.hasLocation != oldWidget.hasLocation) {
      if (widget.showAnimation && widget.hasLocation) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
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
                    AppColor.btnColor.withAlpha((0.4 * 255).toInt()),
                    AppColor.btnColor.withAlpha((0.5 * 255).toInt()),
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

  Widget buildSearchingContent() {
    return Column(
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
          AnimationProviderString.startingToSearchRequests,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          AnimationProviderString.nearbyToYou,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildNotActiveContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.visibility_off_rounded, size: 200, color: Color(0xFF454A70)),
        SizedBox(height: 20),
        Text(
          AnimationProviderString.activateYourAvailability,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          AnimationProviderString.toStartSearchingRequests,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildNotActiveLocation() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_off_rounded, size: 200, color: Color(0xFF454A70)),
        SizedBox(height: 20),
        Text(
          AnimationProviderString.notActiveLocation,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        Text(
          AnimationProviderString.toActivateLocation,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _buildCurrentContent(),
        ),
      ),
    );
  }

  Widget _buildCurrentContent() {
    if (!widget.hasLocation) {
      return KeyedSubtree(
        key: const ValueKey(AnimationProviderKeys.noLocation),
        child: buildNotActiveLocation(),
      );
    } else if (widget.showAnimation) {
      return KeyedSubtree(
        key: const ValueKey(AnimationProviderKeys.searching),
        child: buildSearchingContent(),
      );
    } else {
      return KeyedSubtree(
        key: const ValueKey(AnimationProviderKeys.notActive),
        child: buildNotActiveContent(),
      );
    }
  }
}
