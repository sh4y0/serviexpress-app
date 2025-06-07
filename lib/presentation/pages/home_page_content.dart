import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/model_mock/proveedor_mock.dart';
import 'package:serviexpress_app/data/models/proveedor_model.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';

class HomePageContent extends StatefulWidget {
  final String mapStyle;
  final void Function(bool isMapLoaded) onMapLoaded;
  const HomePageContent({
    super.key,
    required this.mapStyle,
    required this.onMapLoaded,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  static const LatLng _center = LatLng(-8.073506, -79.057020);
  static const double _zoomLevelFar = 14.0;
  static const double _zoomLevelClose = 18.0;

  final ValueNotifier<LatLng?> _currentPositionNotifier = ValueNotifier<LatLng?>(null);
  final ValueNotifier<Circle?> _locationCircleNotifier = ValueNotifier<Circle?>(null);
  final ValueNotifier<double> _circleRadiusNotifier = ValueNotifier<double>(40);
  final ValueNotifier<Set<Marker>> _markersNotifier = ValueNotifier<Set<Marker>>({});
  final ValueNotifier<bool> _shouldShowSheet = ValueNotifier<bool>(true);
  final ValueNotifier<double> _keyboardHeight = ValueNotifier<double>(0.0);
  final GlobalKey<DraggableSheetSolicitarServicioState> _sheet2Key = GlobalKey<DraggableSheetSolicitarServicioState>();
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(-1);
  final List<ProveedorModel> _proveedoresSeleccionados = [];
  final MapMovementController _movementController = MapMovementController();

  BitmapDescriptor? _locationMarkerIcon;
  BitmapDescriptor? _providerMarkerIcon;

  bool _isZoomedIn = false;
  bool _isSheetVisibleSolicitarServicio = false;
  bool _isSheetVisibleDetalleProveedor = false;
  bool _isMapBeingMoved = false;
  bool _isSolicitudGuardadaFromServicioDetallado = false;
  bool _isProveedorAgregado = false;

  String? _categoriaTemporalDeSheet2;
  String? _activeProgrammaticOperationId;

  late GoogleMapController mapController;
  ServiceModel? _datosSolicitudGuardada;
  ProveedorModel? _selectedProvider;
  Timer? _mapInteractionTimer;
  List<ProveedorModel> _currentProviders = [];
  MarkerId? _currentlyOpenInfoWindowMarkerId;

  @override
  void initState() {
    super.initState();
    _setupLocation();
    _loadMarkerIcon();
    _loadProviderMarkerIcon();
    _initializeLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListener();
    });
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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onMapLoaded(true);
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
    _activeProgrammaticOperationId =
        'zoom_toggle_${DateTime.now().millisecondsSinceEpoch}';
    _movementController.startProgrammaticMove(_activeProgrammaticOperationId!);

    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition == null) {
      _movementController.endProgrammaticMove(_activeProgrammaticOperationId!);
      _activeProgrammaticOperationId = null;
      return;
    }

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
          setState(() {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: currentPosition,
            );
          });
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
        _activeProgrammaticOperationId =
            'category_selection_adjust_${DateTime.now().millisecondsSinceEpoch}';
        _movementController.startProgrammaticMove(
          _activeProgrammaticOperationId!,
        );
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

  void _onCameraMove(CameraPosition? position) {
    if (_movementController.isProgrammaticMove) {
      _shouldShowSheet.value = true;
      return;
    }

    if (!_isMapBeingMoved) {
      _isMapBeingMoved = true;
      _shouldShowSheet.value = false;
    }

    _mapInteractionTimer?.cancel();
    _mapInteractionTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && _isMapBeingMoved) {
        _isMapBeingMoved = false;
      }
    });
  }

  void _onCameraIdle() {
    if (_activeProgrammaticOperationId != null) {
      _movementController.endProgrammaticMove(_activeProgrammaticOperationId!);
      _activeProgrammaticOperationId = null;
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
    }
  }

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
      if (_proveedoresSeleccionados.isEmpty) {
        _isSolicitudGuardadaFromServicioDetallado = false;
        _isProveedorAgregado = false;
      }
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

  void isProveedorAgregado(bool proveedorAgregado) {
    _isProveedorAgregado = proveedorAgregado;
  }

  Widget _buildHomePage() {
    final mediaQuery = MediaQuery.of(context);
    final double topPaddingHeight = 60.0 + 25.0 + mediaQuery.padding.top;
    final double bottomSheetInitialHeight = mediaQuery.size.height * 0.34;

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
                  style: widget.mapStyle,
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
                    top: MediaQuery.of(context).size.height * 0.60,
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
            color: Colors.black.withAlpha((0.3 * 255).toInt()),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomePage();
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
