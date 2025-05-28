import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';

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
  //final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(0);

  BitmapDescriptor? _locationMarkerIcon;

  bool _isSheetVisibleSolicitarServicio = false;
  bool _isSheetVisibleDetalleProveedor = false;

  //Marker? _selectedMarkerData;

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
      final newMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentPosition,
        icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        zIndex: 2,
        onTap: () {
          _showCustomSheet(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: currentPosition,
            ),
          );
        },
      );
      _markersNotifier.value = {newMarker};
    } else {
      _markersNotifier.value = {};
    }
  }

  void _showCustomSheet(Marker tappedMarker) {
    setState(() {
      //_selectedMarkerData = tappedMarker;
      _isSheetVisibleDetalleProveedor = true;
    });
  }

  void _handleSheetDismissedDetalleProveedor() {
    if (mounted) {
      setState(() {
        _isSheetVisibleDetalleProveedor = false;
        //_selectedMarkerData = null;
      });
    }
  }

  void _requestService() {
    setState(() {
      _isSheetVisibleSolicitarServicio = true;
      print(
        '_isSheetVisibleSolicitarServicio $_isSheetVisibleSolicitarServicio',
      );
    });
  }

  void _handleSheetDismissedSolicitarServicio() {
    if (mounted) {
      setState(() {
        _isSheetVisibleSolicitarServicio = false;
      });
    }
  }

  final List<Map<String, dynamic>> drivers = [
    {
      "name": "Carlos",
      "description": "Arregla una lavadora",
      "distance": "A 30 min de ti",
    },
    {
      "name": "Ana",
      "description": "Arregla una lavadora",
      "distance": "2.7 km",
    },
    {
      "name": "Luis",
      "description": "Arregla una lavadora",
      "distance": "4.1 km",
    },
    {
      "name": "Luis",
      "description": "Arregla una lavadora",
      "distance": "4.1 km",
    },
  ];
  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 15;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    mapToolbarEnabled: false,
                  );
                },
              );
            },
          ),
          Positioned(
            top: topPadding,
            left: 16,
            right: 16,
            child: Column(
              children:
                  drivers.map((driver) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColor.bgAll,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver["name"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    driver["description"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    driver["distance"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              const Icon(
                                Icons.home_repair_service,
                                color: Colors.lightGreenAccent,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // SafeArea(
          //   child: Container(
          //     height: 56,
          //     margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 39),
          //     child: ValueListenableBuilder<int>(
          //       valueListenable: _selectedCategoryIndex,
          //       builder: (context, selectedIndex, _) {
          //         return ListView.builder(
          //           padding: const EdgeInsets.all(10),
          //           scrollDirection: Axis.horizontal,
          //           itemBuilder: (context, index) {
          //             var category = CategoryModel.getCategories()[index];
          //             //final bool isSelected = index == selectedIndex;

          //             return CategoryButton(
          //               category: category,
          //               index: index,
          //               selectedCategoryIndexNotifier:
          //                   _selectedCategoryIndex,
          //             );
          //           },
          //           itemCount: DataMock.mockData.length,
          //         );
          //       },
          //     ),
          //   ),
          // ),
          Positioned(
            bottom: 32,
            left: 16,
            child: SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                heroTag: 'fabHomeLeft',
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF0c0c14),
                onPressed: _requestService,
                child: SvgPicture.asset(
                  'assets/icons/ic_request_service.svg',
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
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
                heroTag: 'fabHomeRight',
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
          if (_isSheetVisibleSolicitarServicio)
            Positioned.fill(
              child: DraggableSheetSolicitarServicio(
                targetInitialSize: 0.5,
                minSheetSize: 0.0,
                maxSheetSize: 0.95,
                snapPoints: const [0.0, 0.5, 0.95],
                onDismiss: _handleSheetDismissedSolicitarServicio,
              ),
            ),

          if (_isSheetVisibleDetalleProveedor)
            Positioned.fill(
              child: DraggableSheetDetalleProveedor(
                targetInitialSize: 0.65,
                minSheetSize: 0.0,
                maxSheetSize: 0.95,
                snapPoints: const [0.0, 0.65, 0.95],
                onDismiss: _handleSheetDismissedDetalleProveedor,
              ),
            ),
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
    //_selectedCategoryIndex.dispose();
    //mapController.dispose();
    super.dispose();
  }
}
