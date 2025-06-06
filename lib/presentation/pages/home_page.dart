import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/messaging/notifiaction/notification_manager.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';
import 'package:serviexpress_app/presentation/widgets/profile_screen.dart';
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
  bool _isSheetVisibleSolicitarServicioDetallado = false;
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
  List<UserModel> _currentProviders = [];
  late final UserModel _selectedProvider;
  MarkerId? _currentlyOpenInfoWindowMarkerId;

  final List<UserModel> _proveedoresSeleccionados = [];
  bool _isSolicitudGuardadaFromServicioDetallado = false;

  int _selectedIndex = 0;
  late final List<Widget Function()> _screens;
  bool _isProveedorAgregado = false;

  @override
  void initState() {
    super.initState();
    _screens = [
      () => _buildHomePage(),
      () => const Center(
        child: Text("Conversar", style: TextStyle(fontSize: 25)),
      ),
      () => const ProfileScreen(isProvider: false),
    ];
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
      final markerId = MarkerId('provider_${provider.uid}');
      final providerMarker = Marker(
        markerId: MarkerId('provider_${provider.uid}'),
        position: LatLng(provider.latitud!, provider.longitud!),
        icon:
            _providerMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 1.0),
        zIndex: 1,
        infoWindow: InfoWindow(
          title: provider.nombreCompleto,
          snippet: '⭐ ${provider.calificacion} - ${provider.descripcion}',
        ),
        onTap: () {
          _selectedProvider = provider;
          _currentlyOpenInfoWindowMarkerId = markerId;
          _showCustomSheet(
            Marker(
              markerId: MarkerId('provider_${provider.uid}'),
              position: LatLng(provider.latitud!, provider.longitud!),
            ),
          );
        },
      );
      newMarkers.add(providerMarker);
    }

    _markersNotifier.value = newMarkers;
  }

  void _onCategorySelected(int index) async {
    _selectedCategoryIndex.value = index;

    if (index >= 0 && index < CategoryMock.getCategories().length) {
      String selectedCategory = CategoryMock.getCategories()[index].name;

      final providers = await UserRepository.instance.findByCategory(
        selectedCategory,
      );

      setState(() {
        _currentProviders = providers;
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

    double minLat = _currentProviders.first.latitud!;
    double maxLat = _currentProviders.first.latitud!;
    double minLng = _currentProviders.first.longitud!;
    double maxLng = _currentProviders.first.longitud!;

    for (var provider in _currentProviders) {
      minLat = math.min(minLat, provider.latitud!);
      maxLat = math.max(maxLat, provider.latitud!);
      minLng = math.min(minLng, provider.longitud!);
      maxLng = math.max(maxLng, provider.longitud!);
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

  void _isSolicitudGuardadaOnTapped(bool isSolicitudGuardada) {
    _isSolicitudGuardadaFromServicioDetallado = isSolicitudGuardada;
  }

  void _agregarProveedor(UserModel proveedor) {
    setState(() {
      if (!_proveedoresSeleccionados.any((p) => p.uid == proveedor.uid)) {
        _proveedoresSeleccionados.add(proveedor);
      }
      if (_proveedoresSeleccionados.length == 1) {
        _isSheetVisibleSolicitarServicioDetallado = true;
      }
    });
  }

  void _removerProveedor(UserModel proveedor) {
    setState(() {
      _proveedoresSeleccionados.removeWhere((p) => p.uid == proveedor.uid);
      if (_proveedoresSeleccionados.isEmpty) {
        _isSheetVisibleSolicitarServicioDetallado = false;
        _isSolicitudGuardadaFromServicioDetallado = false;
        _isProveedorAgregado = false;
      }
    });
  }

  void _abrirDetalleProveedor(UserModel proveedor) {
    setState(() {
      _selectedProvider = UserModel(
        uid: proveedor.uid,
        nombreCompleto: proveedor.nombreCompleto,
        especialidad: proveedor.especialidad,
        calificacion: proveedor.calificacion,
        descripcion: proveedor.descripcion,
        imagenUrl: proveedor.imagenUrl,
        username: proveedor.username,
        email: proveedor.email,
        dni: proveedor.dni,
        telefono: proveedor.telefono,
        nombres: proveedor.nombres,
        apellidoPaterno: proveedor.apellidoPaterno,
        apellidoMaterno: proveedor.apellidoMaterno,
      );
      _isSheetVisibleDetalleProveedor = true;
    });
  }

  void isProveedorAgregado(bool proveedorAgregado) {
    _isProveedorAgregado = proveedorAgregado;
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

  Widget _buildHomePage() {
    final double topPaddingHeight =
        60.0 + 25.0 + MediaQuery.of(context).padding.top;
    final double bottomSheetInitialHeight =
        MediaQuery.of(context).size.height * 0.34;
    return Stack(
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
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 6,
          right: 6,
          height: 110,
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
                                isSelected ? Colors.white : AppColor.textInput,
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

        // if (!_isSheetVisibleSolicitarServicioDetallado)
        //   Positioned(
        //     bottom: MediaQuery.of(context).size.height * 0.01,
        //     right: 10,
        //     child: SizedBox(
        //       width: 50,
        //       height: 50,
        //       child: FloatingActionButton(
        //         heroTag: 'fabHomeRightsheet',
        //         shape: const CircleBorder(),
        //         backgroundColor: const Color(0xFF4a66ff),
        //         onPressed: _toggleZoom,
        //         child: SvgPicture.asset(
        //           'assets/icons/ic_current_location.svg',
        //           width: 26,
        //           height: 26,
        //           colorFilter: const ColorFilter.mode(
        //             Colors.white,
        //             BlendMode.srcIn,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),

        //if (_isSheetVisibleSolicitarServicioDetallado)
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
                  bottom: shouldShow ? 0 : -MediaQuery.of(context).size.height,
                  top: 0,
                  child: DraggableSheetSolicitarServicio(
                    key: _sheet2Key,
                    targetInitialSize: 0.30,
                    minSheetSize: 0.30,
                    maxSheetSize: 0.95,
                    snapPoints: const [0.30, 0.95],
                    onTapPressed: _requestService,
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
                    isSolicitudGuardada:
                        _isSolicitudGuardadaFromServicioDetallado,
                    isProveedorAgregado: _isProveedorAgregado,
                  ),
                ),
                if (shouldShow)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.52,
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
              isSolicitudEnviada: (isSolicitudEnviada) {
                _isSolicitudGuardadaOnTapped(isSolicitudEnviada);
              },
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
              isProveedorAgregado: (proveedorAgregado) {
                isProveedorAgregado(proveedorAgregado);
              },
            ),
          ),
        ],
        if (!_mapLoaded) Positioned.fill(child: _buildSkeletonPlaceholder()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: _screens[_selectedIndex](),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColor.bgBtnNav,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/icons/ic_home.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? AppColor.dotColor : AppColor.bgItmNav,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/icons/ic_chat.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? AppColor.dotColor : AppColor.bgItmNav,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Conversar",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                "assets/icons/ic_person.svg",
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? AppColor.dotColor : AppColor.bgItmNav,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: "Mi Perfil",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColor.dotColor,
        unselectedItemColor: AppColor.bgItmNav,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        enableFeedback: true,
        elevation: 15,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
