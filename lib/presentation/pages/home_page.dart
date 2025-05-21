import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/category_model.dart';
import 'package:serviexpress_app/data/models/data_mock.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet.dart';

class HomePage extends StatefulWidget {
  final String mapStyle;
  const HomePage({super.key, required this.mapStyle});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  static const LatLng _center = LatLng(-8.073506, -79.057020);

  bool _isZoomedIn = false;

  static const double _zoomLevelFar = 14.0;
  static const double _zoomLevelClose = 18.0;

  final ValueNotifier<LatLng?> _currentPositionNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<Circle?> _locationCircleNotifier = ValueNotifier<Circle?>(
    null,
  );
  final ValueNotifier<double> _circleRadiusNotifier = ValueNotifier<double>(40);
  final ValueNotifier<Set<Marker>> _markersNotifier =
      ValueNotifier<Set<Marker>>({});
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(0);

  BitmapDescriptor? _locationMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
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

  Future<void> _toggleZoom() async {
    if (_currentPositionNotifier.value == null) {
      await _getCurrentLocation(forceUpdate: true);
      return;
    }

    _isZoomedIn = !_isZoomedIn;
    _animateCameraBasedOnZoomState();
  }

  void _animateCameraBasedOnZoomState() {
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition == null) return;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPosition,
          zoom: _isZoomedIn ? _zoomLevelClose : _zoomLevelFar,
          bearing: 0.0,
          tilt: 0.0,
        ),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _getCurrentLocation({bool forceUpdate = false}) async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);

      bool shouldUpdate =
          forceUpdate ||
          _currentPositionNotifier.value == null ||
          _calculateDistance(_currentPositionNotifier.value!, newPosition) > 5;

      if (shouldUpdate) {
        _currentPositionNotifier.value = newPosition;
        _updateLocationCircle();
        _updateMarkers();

        if (forceUpdate) {
          _isZoomedIn = true;
        }

        _animateCameraBasedOnZoomState();
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ValueListenableBuilder<Circle?>(
            valueListenable: _locationCircleNotifier,
            builder: (context, locationCircle, _) {
              final Set<Circle> circles =
                  locationCircle != null ? {locationCircle} : {};
              return ValueListenableBuilder<Set<Marker>>(
                valueListenable: _markersNotifier,
                builder: (context, markers, _) {
                  return GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: _zoomLevelFar,
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

          SafeArea(
            child: Container(
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 39),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedCategoryIndex,
                builder: (context, selectedIndex, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var category = CategoryModel.getCategories()[index];
                      final bool isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: MaterialButton(
                          padding: const EdgeInsets.all(10),
                          height: 39,
                          minWidth: 98,
                          color:
                              isSelected
                                  ? const Color(0xFF3645f5)
                                  : const Color(0xFF263089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onPressed: () {
                            _selectedCategoryIndex.value = index;
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                category.iconPath,
                                width: 20,
                                height: 15,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? Colors.white
                                      : AppColor.textInput,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                category.name,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColor.textInput,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: DataMock.mockData.length,
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            right: 16,
            child: SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF0c0c14),
                onPressed: _toggleZoom,
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
          ),
          const DraggableSheet(child: SizedBox(height: 100)),
        ],
      ),
      // floatingActionButton: SizedBox(
      //   width: 60,
      //   height: 60,
      //   child: FloatingActionButton(
      //     shape: const CircleBorder(),
      //     backgroundColor: const Color(0xFF0c0c14),
      //     onPressed: _toggleZoom,
      //     child: SvgPicture.asset(
      //       'assets/icons/ic_current_location.svg',
      //       width: 26,
      //       height: 26,
      //       colorFilter: const ColorFilter.mode(
      //         Color(0xFF4a4757),
      //         BlendMode.srcIn,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  @override
  void dispose() {
    _currentPositionNotifier.dispose();
    _locationCircleNotifier.dispose();
    _circleRadiusNotifier.dispose();
    _markersNotifier.dispose();
    _selectedCategoryIndex.dispose();
    mapController.dispose();
    super.dispose();
  }
}
