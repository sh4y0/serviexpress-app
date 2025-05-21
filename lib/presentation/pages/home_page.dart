import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  final String mapStyle;
  const HomePage({super.key, required this.mapStyle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  static const LatLng _center = LatLng(-8.073506, -79.057020);

  final ValueNotifier<LatLng?> _currentPositionNotifier = ValueNotifier<LatLng?>(null);
  final ValueNotifier<Circle?> _locationCircleNotifier = ValueNotifier<Circle?>(null);
  final ValueNotifier<double> _circleRadiusNotifier = ValueNotifier<double>(40);
  final ValueNotifier<Set<Marker>> _markersNotifier = ValueNotifier<Set<Marker>>({});
  
  //late AnimationController _animationController;
  BitmapDescriptor? _locationMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
    //_setupAnimation();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    try {
      Position position =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

      final newPosition = LatLng(position.latitude, position.longitude);
      _currentPositionNotifier.value = newPosition;
      _updateLocationCircle();
      _updateMarkers();
      _moveCameraToCurrentPosition();
    } catch (e) {
      debugPrint('Error al inicializar la ubicación: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(widget.mapStyle);
  }

  void _loadMarkerIcon() async {
    try {
      _locationMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(24, 24)),
        'assets/icons/ic_location.png',
      );
      _updateMarkers();
    } catch (e) {
      debugPrint('Error cargando icono: $e');
      _locationMarkerIcon = BitmapDescriptor.defaultMarker;
      _updateMarkers();
    }
  }

  // void _setupAnimation() {
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 2),
  //   )..repeat(reverse: true);

  //   _animationController.addListener(() {
  //     if (_currentPositionNotifier.value != null) {
  //       _circleRadiusNotifier.value = 25 + (25 * _animationController.value);
  //       _updateLocationCircle();
  //     }
  //   });
  // }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El servicio de ubicación está desactivado'),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    if (_currentPositionNotifier.value != null) {
      _moveCameraToCurrentPosition();
    }

    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);

      if (_currentPositionNotifier.value == null ||
          _calculateDistance(_currentPositionNotifier.value!, newPosition) > 5) {
        _currentPositionNotifier.value = newPosition;
        _updateLocationCircle();
        _updateMarkers();
        _moveCameraToCurrentPosition();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar la ubicación'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  void _moveCameraToCurrentPosition() {
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentPosition,
            zoom: 14.0,
            bearing: 0.0,
            tilt: 0.0,
          ),
        ),
      );
    }
  }

  void _updateLocationCircle() {
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition != null) {
      _locationCircleNotifier.value = Circle(
        circleId: const CircleId('currentLocation'),
        center: currentPosition,
        radius: _circleRadiusNotifier.value,
        strokeWidth: 2,
        strokeColor: const Color.fromRGBO(74, 102, 255, 0.5),
        fillColor: const Color.fromRGBO(74, 102, 255, 0.2),
        zIndex: 1,
      );
    }
  }

  void _updateMarkers() {
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition != null) {
      _markersNotifier.value = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentPosition,
          icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<Circle?>(
            valueListenable: _locationCircleNotifier,
            builder: (context, locationCircle, _) {
              final Set<Circle> circles = locationCircle != null ? {locationCircle} : {};
              
              return ValueListenableBuilder<Set<Marker>>(
                valueListenable: _markersNotifier,
                builder: (context, markers, _) {
                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: 20.0,
                    ),
                    circles: circles,
                    markers: markers,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF0c0c14),
          onPressed: _getCurrentLocation,
          child: SvgPicture.asset(
            'assets/icons/ic_current_location.svg',
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Color(0xFF4a4757),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPositionNotifier.dispose();
    _locationCircleNotifier.dispose();
    _circleRadiusNotifier.dispose();
    _markersNotifier.dispose();
    
    //_animationController.dispose();
    mapController.dispose();
    super.dispose();
  }
}