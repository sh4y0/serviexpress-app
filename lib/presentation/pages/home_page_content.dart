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
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/widgets/animation_home.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  static const double _zoomLevelClose = 18.0;

  final ValueNotifier<LatLng?> _currentPositionNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<Circle?> _locationCircleNotifier = ValueNotifier<Circle?>(
    null,
  );
  final ValueNotifier<double> _circleRadiusNotifier = ValueNotifier<double>(40);
  final ValueNotifier<Set<Marker>> _markersNotifier =
      ValueNotifier<Set<Marker>>({});
  final ValueNotifier<bool> _shouldShowSheet = ValueNotifier<bool>(true);
  final ValueNotifier<double> _keyboardHeight = ValueNotifier<double>(0.0);
  final GlobalKey<DraggableSheetSolicitarServicioState> _sheet2Key =
      GlobalKey<DraggableSheetSolicitarServicioState>();
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(-1);
  final List<UserModel> _proveedoresSeleccionados = [];
  final MapMovementController _movementController = MapMovementController();
  bool _hasShownMarkerTutorial = false;

  BitmapDescriptor? _locationMarkerIcon;
  BitmapDescriptor? _providerMarkerIcon;

  bool _isZoomedIn = false;
  bool _isSheetVisibleSolicitarServicio = false;
  bool _isSheetVisibleDetalleProveedor = false;
  bool _isMapBeingMoved = false;
  bool _isSolicitudGuardadaFromServicioDetallado = false;
  bool _isProveedorAgregado = false;
  bool _categoriaError = false;

  String? _categoriaTemporalDeSheet2;
  String? _activeProgrammaticOperationId;

  late GoogleMapController mapController;
  ServiceModel? _datosSolicitudGuardada;
  UserModel? _selectedProvider;
  Timer? _mapInteractionTimer;
  List<UserModel> _currentProviders = [];
  MarkerId? _currentlyOpenInfoWindowMarkerId;

  final List<TargetFocus> _targets = [];
  bool _shouldShowSecondTutorialStep = false;
  bool _pendingSecondTutorial = false;
  bool _isTappedSolicitarServicio = false;
  final GlobalKey _firstCategoryKey = GlobalKey();
  final GlobalKey _locationButtonKey = GlobalKey();
  TutorialCoachMark? _tutorialCoachMark;
  final GlobalKey _describirServicioKey = GlobalKey();

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
      textSkip: "SALTAR",
      paddingFocus: 2,
      opacityShadow: 0.8,
      onFinish: () {
        setState(() {
          _shouldShowSecondTutorialStep = true;
        });
      },
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
        _onCategorySelected(0);
        setState(() {
          _shouldShowSecondTutorialStep = true;
        });
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        debugPrint("target: $target");
        debugPrint(
          "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}",
        );
      },
      onClickOverlay: (target) {
        debugPrint('onClickOverlay: $target');
      },
      onSkip: () {
        setState(() {
          _shouldShowSecondTutorialStep = true;
        });
        return true;
      },
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
                    "Selección de Categoría",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "¡Comencemos por aquí! Pulsa esta categoría para ver a los proveedores de servicios en el mapa",
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
      Position position =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

      final newPosition = LatLng(position.latitude, position.longitude);
      _currentPositionNotifier.value = newPosition;
      //_updateLocationCircle();
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
        //_updateLocationCircle();
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

    if (currentPosition != null && _isTappedSolicitarServicio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLocationAnimation(currentPosition);
      });
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
        // infoWindow: InfoWindow(
        //   title: provider.nombreCompleto,
        //   snippet: '⭐ ${provider.calificacion} - ${provider.descripcion}',
        // ),
        onTap: () {
          _selectedProvider = provider;
          _currentlyOpenInfoWindowMarkerId = markerId;
          Marker(
            markerId: MarkerId('provider_${provider.uid}'),
            position: LatLng(provider.latitud!, provider.longitud!),
          );
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

  void _startLocationAnimation(LatLng position) async {
    try {
      await AnimationProvider.startAnimation(
        context,
        mapController,
        position,
        _locationMarkerIcon,
        onComplete: () {
          if (mounted) {
            setState(() {
              _isTappedSolicitarServicio = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTappedSolicitarServicio = false;
        });
      }
    }
  }

  void _onCategorySelected(int index) async {
    setState(() {
      _selectedCategoryIndex.value = index;
      _categoriaError = false;
    });

    if (index >= 0 && index < CategoryMock.getCategories().length) {
      String selectedCategory = CategoryMock.getCategories()[index].name;

      final providers = await UserRepository.instance.findByCategory(
        selectedCategory,
      );

      setState(() {
        _currentProviders = providers;

        if (_shouldShowSecondTutorialStep && _currentProviders.isNotEmpty) {
          _pendingSecondTutorial = true;
          _shouldShowSecondTutorialStep = false;
        } else {
          Future.delayed(
            const Duration(milliseconds: 500),
            _showFallbackTutorial,
          );
        }
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
          if (mounted && _currentProviders.isNotEmpty) {
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
    if (_hasShownMarkerTutorial || _currentProviders.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _hasShownMarkerTutorial = true;
    });

    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 150;
    final bottomSheetHeight = mediaQuery.size.height * 0.24;
    final screenHeight = mediaQuery.size.height;

    for (final provider in _currentProviders) {
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
        } else {
          _showFallbackTutorial();
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
                  "Proveedor de Servicio",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Los íconos azules representan proveedores de la categoría seleccionada. Cuando recibas cotizaciones, podrás tocar un ícono para ver los detalles y decidir si aceptas o rechazas al proveedor.",
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
      paddingFocus: 5,
      opacityShadow: 0.8,
    );

    _tutorialCoachMark?.show(context: context);
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
                    "Encuentra tu Ubicación",
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
        setState(() {
          _attemptToShowMarkersTutorial();
          _shouldShowSecondTutorialStep = false;
        });
      },
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
        _toggleZoom();
        Future.delayed(
          const Duration(seconds: 2),
          _showFourthTutorialStep,
        );
      },
      textSkip: "FINALIZAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
    _tutorialCoachMark?.show(context: context);
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
      onClickTarget: (target) {
        _requestService();
      },
      textSkip: "FINALIZAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    );
    _tutorialCoachMark?.show(context: context);
  }

  void _showFallbackTutorial() {
    final screenSize = MediaQuery.of(context).size;
    const double tutorialSize = 120.0;
    final double centerX = screenSize.width / 2;
    final double centerY = screenSize.height / 2;
    final targetPosition = TargetPosition(
      const Size(tutorialSize, tutorialSize),
      Offset(centerX - tutorialSize / 2, centerY - tutorialSize / 2),
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
                  "Aun no hay proveedores disponibles en esta categoría",
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
    );

    _tutorialCoachMark?.show(context: context);
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

  void _isSolicitudServicioOnTapped(bool? isSolicitarServicio) {
    setState(() {
      _isTappedSolicitarServicio = isSolicitarServicio ?? false;
    });

    if (_isTappedSolicitarServicio) {
      _updateMarkers();
    }
  }

  void _agregarProveedor(UserModel proveedor) {
    setState(() {
      if (!_proveedoresSeleccionados.any((p) => p.uid == proveedor.uid)) {
        _proveedoresSeleccionados.add(proveedor);
      }
    });
  }

  void _removerProveedor(UserModel proveedor) {
    setState(() {
      _proveedoresSeleccionados.removeWhere((p) => p.uid == proveedor.uid);
      if (_proveedoresSeleccionados.isEmpty) {
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
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 60,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _selectedCategoryIndex,
                        builder: (context, selectedIndex, _) {
                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 10,
                              right: 10,
                              bottom: 10,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              var category =
                                  CategoryMock.getCategories()[index];
                              final bool isSelected = index == selectedIndex;
                              final bool showErrorBorder =
                                  _categoriaError && selectedIndex == -1;

                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  decoration:
                                      showErrorBorder
                                          ? BoxDecoration(
                                            border: Border.all(
                                              color: Colors.redAccent,
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          )
                                          : null,
                                  child: MaterialButton(
                                    key: index == 0 ? _firstCategoryKey : null,
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
                                ),
                              );
                            },
                            itemCount: CategoryMock.getCategories().length,
                          );
                        },
                      ),
                    ),
                    if (_categoriaError)
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
          builder: (context, shouldShow, child) {
            final bool hayProveedores =
                _isProveedorAgregado && _proveedoresSeleccionados.isNotEmpty;
            final double minSheetSize = hayProveedores ? 0.40 : 0.21;
            final double maxSheetSize = hayProveedores ? 0.40 : 0.21;
            final List<double> snapPoints =
                hayProveedores ? [0.21, 0.40] : [0.35];
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
                    detallarServicioKey: _describirServicioKey,
                    targetInitialSize: minSheetSize,
                    minSheetSize: minSheetSize,
                    maxSheetSize: maxSheetSize,
                    snapPoints: snapPoints,
                    onTapPressed: () {
                      if (_selectedCategoryIndex.value == -1) {
                        setState(() {
                          _categoriaError = true;
                        });
                        return;
                      }
                      _requestService();
                    },
                    onCategoriaError: () {
                      setState(() {
                        _categoriaError = true;
                      });
                    },
                    categoriaError: _categoriaError,
                    selectedCategoryIndex: _selectedCategoryIndex.value,
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
                    onPressedSolicitarServicio: _isSolicitudServicioOnTapped,
                  ),
                ),
                if (shouldShow)
                  Positioned(
                    bottom:
                        (_isProveedorAgregado &&
                                _proveedoresSeleccionados.isNotEmpty)
                            ? MediaQuery.of(context).size.height * 0.35
                            : MediaQuery.of(context).size.height * 0.22,
                    right: 10,
                    child: SizedBox(
                      width: 50,
                      height: 50,
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
              targetInitialSize: 0.57,
              minSheetSize: 0.0,
              maxSheetSize: 0.95,
              snapPoints: const [0.0, 0.57, 0.95],
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
