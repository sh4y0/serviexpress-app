import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/widgets/animation_home.dart';
import 'package:serviexpress_app/presentation/widgets/category_button.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MapMovementController {
  bool _isProgrammaticMove = false;
  String? _operationId;

  bool get isProgrammaticMove => _isProgrammaticMove;

  void startProgrammaticMove(String operationId) {
    _isProgrammaticMove = true;
    _operationId = operationId;
  }

  void endProgrammaticMove(String operationId) {
    if (_operationId == operationId) {
      _isProgrammaticMove = false;
      _operationId = null;
    }
  }
}

class HomePageContent extends StatefulWidget {
  final String mapStyle;
  final VoidCallback onMenuPressed;
  final void Function(bool isMapLoaded) onMapLoaded;

  const HomePageContent({
    super.key,
    required this.mapStyle,
    required this.onMapLoaded,
    required this.onMenuPressed,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  static const LatLng _center = LatLng(-8.073506, -79.057020);
  static const double _zoomLevelFar = 14.0;
  static const double _zoomLevelClose = 16.5;
  final MapMovementController _movementController = MapMovementController();

  final ValueNotifier<LatLng?> _currentPositionNotifier = ValueNotifier(null);
  final ValueNotifier<Circle?> _locationCircleNotifier = ValueNotifier(null);
  final ValueNotifier<Set<Marker>> _markersNotifier = ValueNotifier({});
  final ValueNotifier<bool> _shouldShowSheet = ValueNotifier(true);
  final ValueNotifier<double> _keyboardHeight = ValueNotifier(0.0);
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier(-1);
  final ValueNotifier<List<UserModel>> _currentProvidersNotifier = ValueNotifier([]);
  final ValueNotifier<List<UserModel>> _proveedoresSeleccionadosNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _isSheetVisibleSolicitarServicioNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSheetVisibleDetalleProveedorNotifier = ValueNotifier(false);
  final ValueNotifier<ServiceModel?> _datosSolicitudGuardadaNotifier = ValueNotifier(null);
  final ValueNotifier<UserModel?> _selectedProviderNotifier = ValueNotifier(null,);
  final ValueNotifier<bool> _categoriaErrorNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSolicitudGuardadaNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isProveedorAgregadoNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isTappedSolicitarServicioNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _hasShownMarkerTutorialNotifier = ValueNotifier(false);

   final ValueNotifier<List<UserModel>> _proveedoresNotifier = ValueNotifier([]);

  bool _isZoomedIn = false;
  bool _isMapBeingMoved = false;
  String? _activeProgrammaticOperationId;
  Timer? _mapInteractionTimer;
  MarkerId? _currentlyOpenInfoWindowMarkerId;
  BitmapDescriptor? _locationMarkerIcon;
  BitmapDescriptor? _providerMarkerIcon;
  late GoogleMapController mapController;
  String? _categoriaTemporalDeSheet2;

  final ValueNotifier<bool> _shouldShowSecondTutorialStepNotifier = ValueNotifier(false);
  bool _pendingSecondTutorial = false;
  final GlobalKey _firstCategoryKey = GlobalKey();
  final GlobalKey _locationButtonKey = GlobalKey();
  final GlobalKey _describirServicioKey = GlobalKey();
  TutorialCoachMark? _tutorialCoachMark;
  final List<TargetFocus> _targets = [];

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

  void _showFirstTutorialStep() {
    _initFirstTutorialTarget();
    TutorialCoachMark(
      targets: _targets,
      showSkipInLastTarget: false,
      paddingFocus: 2,
      opacityShadow: 0.8,
      onFinish: () {
        _shouldShowSecondTutorialStepNotifier.value = true;
      },
      onClickTarget: (target) {
        _onCategorySelected(0);
        _shouldShowSecondTutorialStepNotifier.value = true;
      }
    ).show(context: context);
  }

  void _initFirstTutorialTarget() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "first-category-item-key",
        keyTarget: _firstCategoryKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selecciona una Categoría",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¡Este es un pequeño recorrido!. 😊 Elijamos esta categoría para ver los proveedores en el mapa.",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      Position? position =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
      final newPosition = LatLng(position.latitude, position.longitude);
      _currentPositionNotifier.value = newPosition;
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
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showFirstTutorialStep();
          }
        });
      }
    });
  }

  void _loadMarkerIcon() async {
    try {
      _locationMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(25, 25)),
        'assets/icons/ic_location_red.png',
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
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
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
          zoom: _zoomLevelClose,
          bearing: 0.0,
          tilt: 45.0,
        ),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _getCurrentLocation({bool forceUpdate = false}) async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;
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
        _updateMarkers();
        if (forceUpdate) _isZoomedIn = true;
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

  void _updateMarkers() {
    final currentPosition = _currentPositionNotifier.value;
    Set<Marker> newMarkers = {};

    if (currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentPosition,
          icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
          onTap: _animateCameraBasedOnZoomState,
        ),
      );
    }

    if (currentPosition != null && _isTappedSolicitarServicioNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLocationAnimation(currentPosition);
      });
    }

    for (var provider in _currentProvidersNotifier.value) {
      final markerId = MarkerId('provider_${provider.uid}');
      newMarkers.add(
        Marker(
          markerId: markerId,
          position: LatLng(provider.latitud!, provider.longitud!),
          icon:
              _providerMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 1.0),
          zIndex: 1,
          onTap: () {
            _selectedProviderNotifier.value = provider;
            _currentlyOpenInfoWindowMarkerId = markerId;
            //_isSheetVisibleDetalleProveedorNotifier.value = true;
          },
        ),
      );
    }
    _markersNotifier.value = newMarkers;
  }

  void _startLocationAnimation(LatLng position) async {
    try {
      await AnimationHome.startAnimation(
        context,
        mapController,
        position,
        _locationMarkerIcon,
        onComplete: () {
          if (mounted) _isTappedSolicitarServicioNotifier.value = false;
        },
      );
    } catch (e) {
      if (mounted) _isTappedSolicitarServicioNotifier.value = false;
    }
  }

  void _onCategorySelected(int index) async {
    _selectedCategoryIndex.value = index;
    _categoriaErrorNotifier.value = false;
    
    if (index >= 0 && index < CategoryMock.getCategories().length) {
      String selectedCategory = CategoryMock.getCategories()[index].name;
      final providers = await UserRepository.instance.findByCategory(
        selectedCategory,
      );
      _currentProvidersNotifier.value = providers;

      if (_shouldShowSecondTutorialStepNotifier.value && providers.isNotEmpty) {
        _pendingSecondTutorial = true;
        _shouldShowSecondTutorialStepNotifier.value = false;

      } else if (_shouldShowSecondTutorialStepNotifier.value &&
          providers.isEmpty) {
        Future.delayed(
          const Duration(milliseconds: 500),
          _showFallbackTutorial,
        );
        _shouldShowSecondTutorialStepNotifier.value = false;
      }
      _updateMarkers();
      if (providers.isNotEmpty) {
        _activeProgrammaticOperationId =
            'category_selection_adjust_${DateTime.now().millisecondsSinceEpoch}';
        _movementController.startProgrammaticMove(
          _activeProgrammaticOperationId!,
        );
        _adjustCameraToShowAllMarkers();
      }
    } else {
      _currentProvidersNotifier.value = [];
      _updateMarkers();
    }
  }

  void _adjustCameraToShowAllMarkers() {
    if (_currentProvidersNotifier.value.isEmpty) return;
    List<UserModel> providers = _currentProvidersNotifier.value;
    double minLat = providers.first.latitud!;
    double maxLat = providers.first.latitud!;
    double minLng = providers.first.longitud!;
    double maxLng = providers.first.longitud!;

    for (var provider in providers) {
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

  void _handleSheetDismissedDetalleProveedor() {
    if (mounted) {
      _isSheetVisibleDetalleProveedorNotifier.value = false;
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
      
      if (_pendingSecondTutorial) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentProvidersNotifier.value.isNotEmpty) {
            _attemptToShowMarkersTutorial();
          }
        });
        _pendingSecondTutorial = false;
      }
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

  Future<void> _attemptToShowMarkersTutorial() async {
    if (_hasShownMarkerTutorialNotifier.value ||
        _currentProvidersNotifier.value.isEmpty ||
        !mounted) {
      return;
    }

    _hasShownMarkerTutorialNotifier.value = true;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 150;
    final bottomSheetHeight = mediaQuery.size.height * 0.24;
    final screenHeight = mediaQuery.size.height;

    for (final provider in _currentProvidersNotifier.value) {
      try {
        final latLng = LatLng(provider.latitud!, provider.longitud!);
        final screenCoordinate = await mapController.getScreenCoordinate(
          latLng,
        );
        final bool isVisible =
            screenCoordinate.y > topPadding &&
            screenCoordinate.y > (screenHeight - bottomSheetHeight);
      
        if (isVisible) {
          _showTutorialForMarkerAt(screenCoordinate);
          return;
        }
      } catch (e) {
        debugPrint(
          "LogServiExpress - Error al obtener la coordenada para un marcador: $e",
        );
      }
    }
    _showFallbackTutorial();
  }
  void _showTutorialForMarkerAt(ScreenCoordinate markerCoordinate) {
    const double highlightSize = 120.0;
    final double centerX = markerCoordinate.x / 2;
    final double centerY = markerCoordinate.y / 2;

    final targetPosition = TargetPosition(
      const Size(highlightSize, highlightSize),
      Offset(centerX / 2, centerY / 2),
    );

    final target = TargetFocus(
      identify: "marker-focus-tutorial",
      targetPosition: targetPosition,
      shape: ShapeLightFocus.Circle,
      radius: 15,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Proveedores de Servicio",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "🔵  Los puntos azules en el mapa son proveedores de la categoría que elegiste.\n 🤝 Cuando ellos te envíen sus propuestas, podrás tocarlos para ver más detalles y decidir si aceptar o no",
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _tutorialCoachMark?.finish();
                      _showLocationButtonTutorial();
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "Siguiente",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    _tutorialCoachMark = TutorialCoachMark(
      targets: [target],
      hideSkip: true,
      paddingFocus: 5,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  void _showLocationButtonTutorial() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "location-button-key",
        keyTarget: _locationButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Encuentra tu ubicación",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pulsa este botón para centrar el mapa en tu ubicación actual y ver los proveedores más cercanos.",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      onFinish: () {
        _attemptToShowMarkersTutorial();
        _shouldShowSecondTutorialStepNotifier.value = false;
      },
      onClickTarget: (target) {
        _toggleZoom();
        Future.delayed(const Duration(seconds: 2), _showFourthTutorialStep);
      },
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  void _showFourthTutorialStep() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "describir-servicio-key",
        keyTarget: _describirServicioKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Describe tu Servicio",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¿Qué servicio necesitas? Escríbelo aquí?",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      onClickTarget: (target) => _requestService(),
      textSkip: "FINALIZAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  void _showFallbackTutorial() {
    if (_hasShownMarkerTutorialNotifier.value) return;
    _hasShownMarkerTutorialNotifier.value = true;
    final screenSize = MediaQuery.of(context).size;
    const double tutorialSize = 120.0;
    final targetPosition = TargetPosition(
      const Size(tutorialSize, tutorialSize),
      Offset(
        screenSize.width / 2 - tutorialSize / 2,
        screenSize.height / 2 - tutorialSize / 2,
      ),
    );
    final target = TargetFocus(
      identify: "fallback-tutorial",
      targetPosition: targetPosition,
      shape: ShapeLightFocus.Circle,
      radius: 15,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Proveedores en el Mapa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Aun no hay proveedores disponibles en el mapa para esta categoría",
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _tutorialCoachMark?.finish();
                      _showLocationButtonTutorial();
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "Siguiente",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    _tutorialCoachMark = TutorialCoachMark(
      targets: [target],
      textSkip: "FINALIZAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  void _requestService() {
    _isSheetVisibleSolicitarServicioNotifier.value = true;
  }

  void _handleSheetDismissedSolicitarServicio() {
    if (mounted) {
      _isSheetVisibleSolicitarServicioNotifier.value = false;
    }
  }

  void _manejarGuardadoDesdeSheetDetallado(ServiceModel data) {
    if (mounted) {
      _datosSolicitudGuardadaNotifier.value = data;
      _isSheetVisibleSolicitarServicioNotifier.value = false;
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
    _isSheetVisibleSolicitarServicioNotifier.value =
        isSheetVisibleSolicitarServicio ?? false;
  }

  void _isSolicitudServicioOnTapped(bool? isSolicitarServicio) {
    _isTappedSolicitarServicioNotifier.value = isSolicitarServicio ?? false;
    if (_isTappedSolicitarServicioNotifier.value) {
      _updateMarkers();
    }
  }

  // void _agregarProveedor(UserModel proveedor) {
  //   final currentList = List<UserModel>.from(
  //     _proveedoresSeleccionadosNotifier.value,
  //   );
  //   if (!currentList.any((p) => p.uid == proveedor.uid)) {
  //     currentList.add(proveedor);
  //     _proveedoresSeleccionadosNotifier.value = currentList;
  //   }
  // }

  // void _removerProveedor(UserModel proveedor) {
  //   final currentList = List<UserModel>.from(
  //     _proveedoresSeleccionadosNotifier.value,
  //   );
  //   currentList.removeWhere((p) => p.uid == proveedor.uid);
  //   _proveedoresSeleccionadosNotifier.value = currentList;
  //   if (currentList.isEmpty) {
  //     _isSolicitudGuardadaNotifier.value = false;
  //     _isProveedorAgregadoNotifier.value = false;
  //   }
  // }

  // void _abrirDetalleProveedor(UserModel proveedor) {
  //   _selectedProviderNotifier.value = proveedor;
  //   _isSheetVisibleDetalleProveedorNotifier.value = true;
  // }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double topPaddingHeight = 60.0 + 25.0 + mediaQuery.padding.top;
    final double bottomSheetInitialHeight = mediaQuery.size.height * 0.34;

    return Stack(
      children: [
        ValueListenableBuilder<Set<Marker>>(
          valueListenable: _markersNotifier,
          builder: (context, markers, _) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              style: widget.mapStyle,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: _zoomLevelFar,
              ),
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
        ),

        Positioned(
          top: mediaQuery.padding.top,
          left: 6,
          right: 6,
          child: ValueListenableBuilder<bool>(
            valueListenable: _categoriaErrorNotifier,
            builder: (context, hasError, _) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 60,
                          child: CategoryButton(
                            categoriaError: hasError,
                            selectedCategoryIndexNotifier:
                                _selectedCategoryIndex,
                            firstCategoryKey: _firstCategoryKey,
                            onCategorySelected:
                                (category) => _onCategorySelected(category),
                          ),
                        ),
                        if (hasError)
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Selecciona una categoria",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: widget.onMenuPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF303F9F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ),
            ),
          ),
        ),


          ValueListenableBuilder<bool>(
          valueListenable: _shouldShowSheet,
          builder: (context, shouldShow, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              left: 0,
              right: 0,
              bottom: shouldShow ? 0 : -mediaQuery.size.height,
              child: ValueListenableBuilder<List<UserModel>>(
                valueListenable: _currentProvidersNotifier,
                builder: (context, proveedores, _) {
                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            left: 0,
                            right: 0,
                            bottom:
                                shouldShow
                                    ? 0
                                    : -MediaQuery.of(context).size.height,
                            top: 0,
                            child: DraggableSheetSolicitarServicio(
                              detallarServicioKey: _describirServicioKey,
                              targetInitialSize: 0.21,
                              minSheetSize: 0.21,
                              maxSheetSize: 0.21,
                              snapPoints: const [0.35],
                              onTapPressed: () {
                                if (_selectedCategoryIndex.value == -1) {
                                  _categoriaErrorNotifier.value = true;
                                  return;
                                }
                                _requestService();
                              },
                              onCategoriaError: () => _categoriaErrorNotifier.value = true,
                              categoriaError: _categoriaErrorNotifier.value,
                              selectedCategoryIndex: _selectedCategoryIndex.value,
                              onAbrirDetallesPressed:
                                  (isVisible) => _abrirSheetDetalladoDesdeSheet2(isSheetVisibleSolicitarServicio:isVisible),
                              datosSolicitudExistente: _datosSolicitudGuardadaNotifier.value,
                              onProveedores: proveedores,
                              isSolicitudGuardada: _isSolicitudGuardadaNotifier.value,
                              onPressedSolicitarServicio: _isSolicitudServicioOnTapped,
                            ),
                          ),
                          Positioned(
                            bottom: mediaQuery.size.height * 0.22,
                            right: 10,
                            child: FloatingActionButton(
                              key: _locationButtonKey,
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
                        ],
                      );
                },
              ),
            );
          },
        ),


        // ValueListenableBuilder<bool>(
        //   valueListenable: _shouldShowSheet,
        //   builder: (context, shouldShow, _) {
        //     return AnimatedPositioned(
        //       duration: const Duration(milliseconds: 300),
        //       curve: Curves.easeInOut,
        //       top: 0,
        //       left: 0,
        //       right: 0,
        //       bottom: shouldShow ? 0 : -mediaQuery.size.height,
        //       child: ValueListenableBuilder<List<UserModel>>(
        //         valueListenable: _proveedoresSeleccionadosNotifier,
        //         builder: (context, proveedoresSeleccionados, _) {
        //           return ValueListenableBuilder<bool>(
        //             valueListenable: _isProveedorAgregadoNotifier,
        //             builder: (context, isProveedorAgregado, _) {
        //               final bool hayProveedores =
        //                   isProveedorAgregado &&
        //                   proveedoresSeleccionados.isNotEmpty;
        //               final double minSheetSize = hayProveedores ? 0.36 : 0.21;
        //               final double maxSheetSize = hayProveedores ? 0.36 : 0.21;
        //               final List<double> snapPoints =
        //                   hayProveedores ? [0.21, 0.36] : [0.35];

        //               return Stack(
        //                 children: [
        //                   AnimatedPositioned(
        //                     duration: const Duration(milliseconds: 200),
        //                     curve: Curves.easeInOut,
        //                     left: 0,
        //                     right: 0,
        //                     bottom:
        //                         shouldShow
        //                             ? 0
        //                             : -MediaQuery.of(context).size.height,
        //                     top: 0,
        //                     child: DraggableSheetSolicitarServicio(
        //                       detallarServicioKey: _describirServicioKey,
        //                       targetInitialSize: minSheetSize,
        //                       minSheetSize: minSheetSize,
        //                       maxSheetSize: maxSheetSize,
        //                       snapPoints: snapPoints,
        //                       onTapPressed: () {
        //                         if (_selectedCategoryIndex.value == -1) {
        //                           _categoriaErrorNotifier.value = true;
        //                           return;
        //                         }
        //                         _requestService();
        //                       },
        //                       onCategoriaError: () => _categoriaErrorNotifier.value = true,
        //                       categoriaError: _categoriaErrorNotifier.value,
        //                       selectedCategoryIndex: _selectedCategoryIndex.value,
        //                       onAbrirDetallesPressed:
        //                           (isVisible) => _abrirSheetDetalladoDesdeSheet2(isSheetVisibleSolicitarServicio:isVisible),
        //                       datosSolicitudExistente: _datosSolicitudGuardadaNotifier.value,
        //                       proveedoresSeleccionados: proveedoresSeleccionados,
        //                       onProveedorRemovido: _removerProveedor,
        //                       onProveedorTapped: _abrirDetalleProveedor,
        //                       isSolicitudGuardada: _isSolicitudGuardadaNotifier.value,
        //                       isProveedorAgregado: isProveedorAgregado,
        //                       onPressedSolicitarServicio: _isSolicitudServicioOnTapped,
        //                     ),
        //                   ),
        //                   Positioned(
        //                     bottom:
        //                         (hayProveedores
        //                             ? mediaQuery.size.height * 0.37
        //                             : mediaQuery.size.height * 0.22),
        //                     right: 10,
        //                     child: FloatingActionButton(
        //                       key: _locationButtonKey,
        //                       heroTag: 'fabHomeRightsheet',
        //                       shape: const CircleBorder(),
        //                       backgroundColor: const Color(0xFF4a66ff),
        //                       onPressed: _toggleZoom,
        //                       child: SvgPicture.asset(
        //                         'assets/icons/ic_current_location.svg',
        //                         width: 26,
        //                         height: 26,
        //                         colorFilter: const ColorFilter.mode(
        //                           Colors.white,
        //                           BlendMode.srcIn,
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               );
        //             },
        //           );
        //         },
        //       ),
        //     );
        //   },
        // ),

        ValueListenableBuilder<bool>(
          valueListenable: _isSheetVisibleSolicitarServicioNotifier,
          builder: (context, isVisible, _) {
            if (!isVisible) return const SizedBox.shrink();
            return Positioned.fill(
              child: DraggableSheetSolicitarServicioDetallado(
                targetInitialSize: 0.95,
                minSheetSize: 0.0,
                maxSheetSize: 0.95,
                snapPoints: const [0.0, 0.95],
                onDismiss: _handleSheetDismissedSolicitarServicio,
                initialData:
                    _datosSolicitudGuardadaNotifier.value ??
                    ServiceModel(
                      categoria: _categoriaTemporalDeSheet2,
                      id: '',
                      descripcion: '',
                      estado: '',
                      clientId: '',
                      workerId: '',
                    ),
                onGuardarSolicitudCallback:
                    (data) => _manejarGuardadoDesdeSheetDetallado(data),
                selectedCategoryIndex: _selectedCategoryIndex.value,
                isSolicitudEnviada:
                    (isEnviada) =>
                        _isSolicitudGuardadaNotifier.value = isEnviada,
              ),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _isSheetVisibleDetalleProveedorNotifier,
          builder: (context, isVisible, _) {
            if (!isVisible) return const SizedBox.shrink();
            return Positioned.fill(
              child: Stack(
                children: [
                  ModalBarrier(
                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                    dismissible: true,
                    onDismiss: _handleSheetDismissedDetalleProveedor,
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder<UserModel?>(
                      valueListenable: _selectedProviderNotifier,
                      builder: (context, selectedProvider, _) {
                        return DraggableSheetDetalleProveedor(
                          targetInitialSize: 0.57,
                          minSheetSize: 0.0,
                          maxSheetSize: 0.95,
                          snapPoints: const [0.0, 0.57, 0.95],
                          onDismiss: _handleSheetDismissedDetalleProveedor,
                          //onProveedorAgregado: _agregarProveedor,
                          selectedProvider: selectedProvider,
                          isProveedorAgregado:
                              (isAgregado) =>
                                  _isProveedorAgregadoNotifier.value =
                                      isAgregado,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPositionNotifier.dispose();
    _locationCircleNotifier.dispose();
    _markersNotifier.dispose();
    _shouldShowSheet.dispose();
    _keyboardHeight.dispose();
    _selectedCategoryIndex.dispose();
    _currentProvidersNotifier.dispose();
    _proveedoresSeleccionadosNotifier.dispose();
    _isSheetVisibleSolicitarServicioNotifier.dispose();
    _isSheetVisibleDetalleProveedorNotifier.dispose();
    _datosSolicitudGuardadaNotifier.dispose();
    _selectedProviderNotifier.dispose();
    _categoriaErrorNotifier.dispose();
    _isSolicitudGuardadaNotifier.dispose();
    _isProveedorAgregadoNotifier.dispose();
    _isTappedSolicitarServicioNotifier.dispose();
    _shouldShowSecondTutorialStepNotifier.dispose();
    _mapInteractionTimer?.cancel();
    super.dispose();
  }
}
