import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class AnimationHome extends StatefulWidget {
  final Offset markerPosition;
  final BitmapDescriptor? markerIcon;
  final VoidCallback? onAnimationComplete;

  const AnimationHome({
    super.key,
    required this.markerPosition,
    this.markerIcon,
    this.onAnimationComplete,
  });

  @override
  State<AnimationHome> createState() => _AnimationHomeState();

  static Future<void> startAnimation(
    BuildContext context,
    GoogleMapController mapController,
    LatLng markerLatLng,
    BitmapDescriptor? icon, {
    VoidCallback? onComplete,
  }) async {
    try {
      final ScreenCoordinate screenCoordinate = 
          await mapController.getScreenCoordinate(markerLatLng);
    
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final Size screenSize = mediaQuery.size;
      final double devicePixelRatio = mediaQuery.devicePixelRatio;
      final Offset markerPosition = Offset(
        screenCoordinate.x / devicePixelRatio,
        screenCoordinate.y / devicePixelRatio,
      );

      if (markerPosition.dx >= 0 && 
          markerPosition.dx <= screenSize.width &&
          markerPosition.dy >= 0 && 
          markerPosition.dy <= screenSize.height) {
        
        await Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            pageBuilder: (context, animation, secondaryAnimation) => 
                AnimationHome(
                  markerPosition: markerPosition,
                  markerIcon: icon,
                  onAnimationComplete: onComplete,
                ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        onComplete?.call();
      }
    } catch (e) {
      onComplete?.call();
    }
  }
}

class _AnimationHomeState extends State<AnimationHome>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _rippleController.repeat();
    
    await Future.delayed(const Duration(seconds: 10));
    
    if (mounted) {
      await _fadeController.forward();

      widget.onAnimationComplete?.call();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCircle(double delay) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        double progress = (_rippleController.value + delay) % 1;
        double scale = progress;
        double opacity = 1.0 - progress;
        
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.1 + scale * 2.5,
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
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned(
                  left: widget.markerPosition.dx - 60, 
                  top: widget.markerPosition.dy - 60, 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildAnimatedCircle(0.0),
                      _buildAnimatedCircle(0.33),
                      _buildAnimatedCircle(0.66),
                      _buildMarkerIcon(),
                    ],
                  ),
                ),
                
                // Positioned.fill(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       const SizedBox(height: 100),
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 20,
                //           vertical: 12,
                //         ),
                //         decoration: BoxDecoration(
                //           color: AppColor.btnColor.withOpacity(0.5),
                //           borderRadius: BorderRadius.circular(25),
                //           boxShadow: const [
                //             BoxShadow(
                //               color: Colors.black26,
                //               blurRadius: 10,
                //               spreadRadius: 2,
                //             ),
                //           ],
                //         ),
                //         child: const Text(
                //           "Enviando solicitud...",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 16,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}