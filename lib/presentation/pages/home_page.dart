import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/proveedor_model.dart';
import 'package:serviexpress_app/data/models/model_mock/proveedor_mock.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';
import 'package:shimmer/shimmer.dart';

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
  BitmapDescriptor? _locationMarkerIcon;
  bool _isSheetVisibleSolicitarServicio = false;
  bool _isSheetVisibleDetalleProveedor = false;
  Timer? _mapInteractionTimer;
  bool _isMapBeingMoved = false;
  final ValueNotifier<bool> _shouldShowSheet = ValueNotifier<bool>(true);
  final ValueNotifier<double> _keyboardHeight = ValueNotifier<double>(0.0);
  bool _mapLoaded = false;
  bool _ignoreNextCameraMove = false;
  ServiceModel? _datosSolicitudGuardada;
  String? _categoriaTemporalDeSheet2;
  final GlobalKey<DraggableSheetSolicitarServicioState> _sheet2Key =
      GlobalKey<DraggableSheetSolicitarServicioState>();
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(-1);

  BitmapDescriptor? _providerMarkerIcon;
  List<ProveedorModel> _currentProviders = [];
  ProveedorModel? _selectedProvider;
  MarkerId? _currentlyOpenInfoWindowMarkerId;

  final List<ProveedorModel> _proveedoresSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _setupToken();
    _setupLocation();
    _loadMarkerIcon();
    _loadProviderMarkerIcon();
    _initializeLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListener();
    });
  }

  void _setupToken() async {
    await NotificationManager().initialize();
  }

  void _setupLocation() async {
    await LocationMapsService().initialize();
  }

  void _setupKeyboardListener() {
    final mediaQuery = MediaQuery.of(context);
    _keyboardHeight.value = mediaQuery.viewInsets.bottom;
  }

  void _loadProviderMarkerIcon() async {
    try {
      _providerMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(24, 24)),
        'assets/icons/ic_clean2.png',
      );
    } catch (e) {
      debugPrint('Error cargando icono de proveedor: $e');
      _providerMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
    }
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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _mapLoaded = true;
        });
      }
    });
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

    _ignoreNextCameraMove = true;

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
    Set<Marker> newMarkers = {};

    if (currentPosition != null) {
      final locationMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentPosition,
        icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        zIndex: 2,
        onTap: () {
          // setState(() {
          //   Marker(
          //     markerId: const MarkerId('currentLocation'),
          //     position: currentPosition,
          //   );
          // });
          _animateCameraBasedOnZoomState();
        },
      );
      newMarkers.add(locationMarker);
    }

    for (var provider in _currentProviders) {
      final markerId = MarkerId('provider_${provider.id}');
      final providerMarker = Marker(
        markerId: MarkerId('provider_${provider.id}'),
        position: provider.ubicacion!,
        icon:
            _providerMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 1.0),
        zIndex: 1,
        infoWindow: InfoWindow(
          title: provider.nombre,
          snippet: '⭐ ${provider.calificacion} - ${provider.descripcion}',
        ),
        onTap: () {
          _selectedProvider = provider;
          _currentlyOpenInfoWindowMarkerId = markerId;
          _showCustomSheet(
            Marker(
              markerId: MarkerId('provider_${provider.id}'),
              position: provider.ubicacion!,
            ),
          );
        },
      );
      newMarkers.add(providerMarker);
    }

    _markersNotifier.value = newMarkers;
  }

  void _onCategorySelected(int index) {
    _selectedCategoryIndex.value = index;

    if (index >= 0 && index < CategoryMock.getCategories().length) {
      String selectedCategory =
          CategoryMock.getCategories()[index].name.toLowerCase();

      setState(() {
        _currentProviders = ProveedorMock.getProveedoresPorCategoria(
          selectedCategory,
        );
      });

      _updateMarkers();

      if (_currentProviders.isNotEmpty) {
        _adjustCameraToShowAllMarkers();
      }
    } else {
      setState(() {
        _currentProviders = [];
      });
      _updateMarkers();
    }
  }

  void _adjustCameraToShowAllMarkers() {
    if (_currentProviders.isEmpty) return;

    double minLat = _currentProviders.first.ubicacion!.latitude;
    double maxLat = _currentProviders.first.ubicacion!.latitude;
    double minLng = _currentProviders.first.ubicacion!.longitude;
    double maxLng = _currentProviders.first.ubicacion!.longitude;

    for (var provider in _currentProviders) {
      minLat = math.min(minLat, provider.ubicacion!.latitude);
      maxLat = math.max(maxLat, provider.ubicacion!.latitude);
      minLng = math.min(minLng, provider.ubicacion!.longitude);
      maxLng = math.max(maxLng, provider.ubicacion!.longitude);
    }

    if (_currentPositionNotifier.value != null) {
      minLat = math.min(minLat, _currentPositionNotifier.value!.latitude);
      maxLat = math.max(maxLat, _currentPositionNotifier.value!.latitude);
      minLng = math.min(minLng, _currentPositionNotifier.value!.longitude);
      maxLng = math.max(maxLng, _currentPositionNotifier.value!.longitude);
    }

    double padding = 0.01;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  void _showCustomSheet(Marker tappedMarker) {
    setState(() {
      _isSheetVisibleDetalleProveedor = true;
    });
  }

  void _handleSheetDismissedDetalleProveedor() {
    if (mounted) {
      setState(() {
        _isSheetVisibleDetalleProveedor = false;
      });
      _hideCurrentlyOpenInfoWindow();
    }
  }

  void _hideCurrentlyOpenInfoWindow() {
    if (_currentlyOpenInfoWindowMarkerId != null) {
      mapController.hideMarkerInfoWindow(_currentlyOpenInfoWindowMarkerId!);
      _currentlyOpenInfoWindowMarkerId = null;
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (_ignoreNextCameraMove) return;

    if (!_isMapBeingMoved) {
      _isMapBeingMoved = true;
      _shouldShowSheet.value = false;
    }

    _mapInteractionTimer?.cancel();

    _mapInteractionTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _isMapBeingMoved = false;
        _shouldShowSheet.value = true;
      }
    });
  }

  void _onCameraIdle() {
    if (_ignoreNextCameraMove) {
      _ignoreNextCameraMove = false;
      return;
    }

    _mapInteractionTimer?.cancel();
    _mapInteractionTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _isMapBeingMoved = false;
        _shouldShowSheet.value = true;
      }
    });
  }

  void _requestService() {
    setState(() {
      _isSheetVisibleSolicitarServicio = true;
    });
  }

  void _handleSheetDismissedSolicitarServicio() {
    if (mounted) {
      setState(() {
        _isSheetVisibleSolicitarServicio = false;
      });
    }
  }

  void _manejarGuardadoDesdeSheetDetallado(ServiceModel data) {
    if (mounted) {
      setState(() {
        _datosSolicitudGuardada = data;
        _isSheetVisibleSolicitarServicio = false;

        //_categoriaTemporalDeSheet2 = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud Guardada Exitosamente',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xff161a50),
          duration: Duration(seconds: 2),
        ),
      );

      // if (_sheet2Key.currentState != null) {
      //   _sheet2Key.currentState!.resetSheet();
      // }
    }
  }

  // void _limpiarDatosSolicitudActual() {
  //   setState(() {
  //     _datosSolicitudGuardada = null;
  //   });
  // }

  // void _abrirSheetDetalladoDesdeSheet2({String? categoria}) {
  //   setState(() {
  //     if (_datosSolicitudGuardada != null && _datosSolicitudGuardada!.hasData) {
  //       _categoriaTemporalDeSheet2 = _datosSolicitudGuardada!.categoria;
  //     } else {
  //       _categoriaTemporalDeSheet2 = categoria;
  //     }
  //     _isSheetVisibleSolicitarServicio = true;
  //   });
  // }

  void _abrirSheetDetalladoDesdeSheet2({
    bool? isSheetVisibleSolicitarServicio,
  }) {
    setState(() {
      _isSheetVisibleSolicitarServicio = isSheetVisibleSolicitarServicio!;
    });
  }

  void _agregarProveedor(ProveedorModel proveedor) {
    setState(() {
      if (!_proveedoresSeleccionados.any((p) => p.id == proveedor.id)) {
        _proveedoresSeleccionados.add(proveedor);
      }
    });
  }

  void _removerProveedor(ProveedorModel proveedor) {
    setState(() {
      _proveedoresSeleccionados.removeWhere((p) => p.id == proveedor.id);
    });
  }

  void _abrirDetalleProveedor(ProveedorModel proveedor) {
    setState(() {
      _selectedProvider = ProveedorModel(
        id: proveedor.id,
        nombre: proveedor.nombre,
        categoria: proveedor.categoria,
        calificacion: proveedor.calificacion,
        descripcion: proveedor.descripcion,
        imagenUrl: proveedor.imagenUrl,
      );
      _isSheetVisibleDetalleProveedor = true;
    });
  }

  Widget _buildSkeletonPlaceholder() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(38, 48, 137, 1),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(38, 48, 137, 1),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 70,
            child: Shimmer.fromColors(
              baseColor: const Color.fromRGBO(200, 200, 200, 0.3),
              highlightColor: const Color.fromRGBO(255, 255, 255, 0.6),

              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 98,
                      height: 39,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(88, 101, 242, 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSkeletonPlaceholder() {
  //   return Skeletonizer(
  //     enabled: true,
  //     effect: const ShimmerEffect(
  //       baseColor: Color.fromRGBO(38, 48, 137, 1),
  //       highlightColor: Color.fromRGBO(58, 68, 157, 1),
  //       duration: Duration(milliseconds: 1200),
  //     ),
  //     child: Scaffold(
  //       backgroundColor: const Color.fromRGBO(38, 48, 137, 1),
  //       body: Stack(
  //         children: [
  //           Container(
  //             width: double.infinity,
  //             height: double.infinity,
  //             color: const Color.fromRGBO(38, 48, 137, 1),
  //           ),

  //           Positioned(
  //             left: 0,
  //             right: 0,
  //             bottom: 0,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: const Color.fromRGBO(22, 26, 80, 1),
  //                 borderRadius: const BorderRadius.only(
  //                   topLeft: Radius.circular(24),
  //                   topRight: Radius.circular(24),
  //                 ),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: const Color.fromRGBO(
  //                       38,
  //                       48,
  //                       137,
  //                       1,
  //                     ).withOpacity(0.5),
  //                     blurRadius: 10,
  //                     spreadRadius: 1,
  //                     offset: const Offset(0, -2),
  //                   ),
  //                 ],
  //               ),
  //               clipBehavior: Clip.antiAlias,
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 15),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(height: 20),

  //                     Container(
  //                       height: 16,
  //                       width: 150,
  //                       decoration: BoxDecoration(
  //                         color: const Color.fromRGBO(38, 48, 137, 1),
  //                         borderRadius: BorderRadius.circular(4),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 12),

  //                     SizedBox(
  //                       height: 40,
  //                       child: Row(
  //                         children: List.generate(
  //                           3,
  //                           (index) => Container(
  //                             margin: const EdgeInsets.only(right: 12),
  //                             width: 80,
  //                             height: 36,
  //                             decoration: BoxDecoration(
  //                               color: const Color.fromRGBO(38, 48, 137, 1),
  //                               borderRadius: BorderRadius.circular(18),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 16),

  //                     Container(
  //                       height: 60,
  //                       width: double.infinity,
  //                       decoration: BoxDecoration(
  //                         color: const Color.fromRGBO(38, 48, 137, 1),
  //                         borderRadius: BorderRadius.circular(16),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(12),
  //                         child: Row(
  //                           children: [
  //                             Container(
  //                               width: 24,
  //                               height: 24,
  //                               decoration: BoxDecoration(
  //                                 color: const Color.fromRGBO(58, 68, 157, 1),
  //                                 borderRadius: BorderRadius.circular(4),
  //                               ),
  //                             ),
  //                             const SizedBox(width: 12),
  //                             Expanded(
  //                               child: Container(
  //                                 height: 16,
  //                                 decoration: BoxDecoration(
  //                                   color: const Color.fromRGBO(58, 68, 157, 1),
  //                                   borderRadius: BorderRadius.circular(4),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 16),

  //                     Container(
  //                       width: double.infinity,
  //                       height: 48,
  //                       decoration: BoxDecoration(
  //                         color: const Color.fromRGBO(38, 48, 137, 1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double topPaddingHeight =
        60.0 + 25.0 + MediaQuery.of(context).padding.top;
    final double bottomSheetInitialHeight =
        MediaQuery.of(context).size.height * 0.34;

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
                    onCameraMove: _onCameraMove,
                    onCameraIdle: _onCameraIdle,
                    padding: EdgeInsets.only(
                      top: topPaddingHeight,
                      bottom: bottomSheetInitialHeight,
                    ),
                  );
                },
              );
            },
          ),
          SafeArea(
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 25),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedCategoryIndex,
                builder: (context, selectedIndex, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var category = CategoryMock.getCategories()[index];
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
                            _onCategorySelected(index);
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
                    itemCount: CategoryMock.getCategories().length,
                  );
                },
              ),
            ),
          ),

          if (!(_selectedCategoryIndex.value < 0))
            ValueListenableBuilder<bool>(
              valueListenable: _shouldShowSheet,
              builder: (context, shouldShow, child) {
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom:
                          shouldShow ? 0 : -MediaQuery.of(context).size.height,
                      top: 0,
                      child: DraggableSheetSolicitarServicio(
                        key: _sheet2Key,
                        targetInitialSize: 0.34,
                        minSheetSize: 0.34,
                        maxSheetSize: 0.95,
                        snapPoints: const [0.34, 0.95],
                        onTapPressed: _requestService,
                        // onAbrirDetallesPressed: (
                        //   String? categoriaSeleccionada,
                        // ) {
                        //   _abrirSheetDetalladoDesdeSheet2(
                        //     categoria: categoriaSeleccionada,
                        //   );
                        // },
                        onAbrirDetallesPressed: (
                          bool? isSheetVisibleSolicitarServicioTapped,
                        ) {
                          _abrirSheetDetalladoDesdeSheet2(
                            isSheetVisibleSolicitarServicio:
                                isSheetVisibleSolicitarServicioTapped,
                          );
                        },
                        datosSolicitudExistente: _datosSolicitudGuardada,
                        proveedoresSeleccionados: _proveedoresSeleccionados,
                        onProveedorRemovido: _removerProveedor,
                        onProveedorTapped: _abrirDetalleProveedor,
                        //selectedCategoryIndex: _selectedCategoryIndex.value,
                      ),
                    ),

                    if (shouldShow)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.63,
                        right: 10,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            heroTag: 'fabHomeRightsheet',
                            shape: const CircleBorder(),
                            backgroundColor: const Color(0xFF4a66ff),
                            onPressed: _toggleZoom,
                            child: SvgPicture.asset(
                              'assets/icons/ic_current_location.svg',
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
                  ],
                );
              },
            ),

          if (_isSheetVisibleSolicitarServicio)
            Positioned.fill(
              child: DraggableSheetSolicitarServicioDetallado(
                targetInitialSize: 0.95,
                minSheetSize: 0.0,
                maxSheetSize: 0.95,
                snapPoints: const [0.0, 0.95],
                onDismiss: _handleSheetDismissedSolicitarServicio,
                initialData:
                    _datosSolicitudGuardada ??
                    ServiceModel(
                      categoria: _categoriaTemporalDeSheet2,
                      id: '',
                      descripcion: '',
                      estado: '',
                      clientId: '',
                      workerId: '',
                    ),
                onGuardarSolicitudCallback: (data) {
                  _manejarGuardadoDesdeSheetDetallado(data);
                },
                selectedCategoryIndex: _selectedCategoryIndex.value,
              ),
            ),

          if (_isSheetVisibleDetalleProveedor) ...[
            ModalBarrier(
              color: Colors.black.withOpacity(0.3),
              dismissible: true,
              onDismiss: _handleSheetDismissedDetalleProveedor,
            ),
            Positioned.fill(
              child: DraggableSheetDetalleProveedor(
                targetInitialSize: 0.55,
                minSheetSize: 0.0,
                maxSheetSize: 0.95,
                snapPoints: const [0.0, 0.55, 0.95],
                onDismiss: _handleSheetDismissedDetalleProveedor,
                onProveedorAgregado: _agregarProveedor,
                selectedProvider: _selectedProvider,
              ),
            ),
          ],

          if (!_mapLoaded) Positioned.fill(child: _buildSkeletonPlaceholder()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPositionNotifier.dispose();
    _locationCircleNotifier.dispose();
    _circleRadiusNotifier.dispose();
    _markersNotifier.dispose();
    super.dispose();
  }
}
