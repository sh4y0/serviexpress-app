import 'package:flutter/material.dart';

class LocationNotFoundBanner extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const LocationNotFoundBanner({super.key, this.onTap, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration:  const BoxDecoration(
        color:  Color(0xFFE6A024),
        boxShadow:  [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No pudimos encontrarte",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text(
                      "Toca para activar la ubicación",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchingLocationBanner extends StatefulWidget {
  final VoidCallback? onCancel;

  const SearchingLocationBanner({super.key, this.onCancel});

  @override
  State<SearchingLocationBanner> createState() =>
      _SearchingLocationBannerState();
}

class _SearchingLocationBannerState extends State<SearchingLocationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(74,102,255,1),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Buscándote en el mapa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Estamos ubicándote, por favor espera un momento…",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (widget.onCancel != null)
              GestureDetector(
                onTap: widget.onCancel,
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class LocationBannerController extends StatefulWidget {
  final Widget child;
  final LocationBannerState bannerState;
  final VoidCallback? onLocationPermissionTap;
  final VoidCallback? onSearchCancel;
  final VoidCallback? onBannerDismiss;

  const LocationBannerController({
    super.key,
    required this.child,
    required this.bannerState,
    this.onLocationPermissionTap,
    this.onSearchCancel,
    this.onBannerDismiss,
  });

  @override
  State<LocationBannerController> createState() =>
      _LocationBannerControllerState();
}

class _LocationBannerControllerState extends State<LocationBannerController>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(LocationBannerController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerState != widget.bannerState) {
      _handleBannerStateChange();
    }
  }

  void _handleBannerStateChange() {
    switch (widget.bannerState) {
      case LocationBannerState.hidden:
        _slideController.reverse();
        break;
      case LocationBannerState.notFound:
      case LocationBannerState.searching:
        _slideController.forward();
        break;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildCurrentBanner() {
    switch (widget.bannerState) {
      case LocationBannerState.notFound:
        return LocationNotFoundBanner(
          onTap: widget.onLocationPermissionTap,
          onDismiss: widget.onBannerDismiss,
        );
      case LocationBannerState.searching:
        return SearchingLocationBanner(onCancel: widget.onSearchCancel);
      case LocationBannerState.hidden:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.bannerState != LocationBannerState.hidden)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildCurrentBanner(),
            ),
          ),
      ],
    );
  }
}

enum LocationBannerState { hidden, notFound, searching }
