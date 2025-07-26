import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class AnimationHome extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final Duration animationDuration;

  const AnimationHome({
    super.key,
    required this.onAnimationComplete,
    this.animationDuration = const Duration(seconds: 20)
  });

  @override
  State<AnimationHome> createState() => _AnimationHomeState();
}

class _AnimationHomeState extends State<AnimationHome> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  void _startAnimation() {
    _rippleController.repeat();

    _completionTimer = Timer(widget.animationDuration, () {
      if (mounted) {
        _fadeController.forward().whenComplete(() {
          if (mounted) {
            widget.onAnimationComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCircle(double delay) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final progress = (_rippleController.value + delay) % 1;
        final scale = 0.1 + progress * 2.5;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColor.btnColor.withAlpha((0.3 * 255).toInt()),
                    AppColor.btnColor.withAlpha((0.6 * 255).toInt()),
                    AppColor.btnColor.withAlpha((0.2 * 255).toInt()),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                border: Border.all(
                  color: AppColor.btnColor.withAlpha((0.8 * 255).toInt()),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarkerIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.btnColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.btnColor.withAlpha((0.5 * 255).toInt()),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildAnimatedCircle(0.0),
          _buildAnimatedCircle(0.33),
          _buildAnimatedCircle(0.66),
          _buildMarkerIcon(),
        ],
      ),
    );
  }
}