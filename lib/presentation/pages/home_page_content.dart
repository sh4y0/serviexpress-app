import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/propuesta_model.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/propuesta_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';
import 'package:serviexpress_app/presentation/widgets/animation_home.dart';
import 'package:serviexpress_app/presentation/widgets/ballon_tail_painter.dart';
import 'package:serviexpress_app/presentation/widgets/category_button.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_solicitar_servicio_detallado.dart';
import 'package:serviexpress_app/presentation/widgets/location_not_found_banner.dart';
import 'package:serviexpress_app/presentation/widgets/proposal_marker_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _HomePageContentState extends State<HomePageContent>
    with TickerProviderStateMixin {
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
  final ValueNotifier<Set<UserModel>> _currentProvidersNotifier = ValueNotifier(
    {},
  );
  final ValueNotifier<List<UserModel>> _proveedoresSeleccionadosNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> _isSheetVisibleSolicitarServicioNotifier =
      ValueNotifier(false);
  final ValueNotifier<bool> _isSheetVisibleDetalleProveedorNotifier =
      ValueNotifier(false);
  final ValueNotifier<ServiceModel?> _datosSolicitudGuardadaNotifier =
      ValueNotifier(null);
  final ValueNotifier<UserModel?> _selectedProviderNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<bool> _categoriaErrorNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSolicitudGuardadaNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isProveedorAgregadoNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isTappedSolicitarServicioNotifier = ValueNotifier(
    false,
  );
  final ValueNotifier<bool> _hasShownMarkerTutorialNotifier = ValueNotifier(
    false,
  );

  bool _isZoomedIn = false;
  bool _isMapBeingMoved = false;
  String? _activeProgrammaticOperationId;
  Timer? _mapInteractionTimer;
  MarkerId? _currentlyOpenInfoWindowMarkerId;
  BitmapDescriptor? _locationMarkerIcon;
  BitmapDescriptor? _providerMarkerIcon;
  GoogleMapController? mapController;
  String? _categoriaTemporalDeSheet2;

  final ValueNotifier<bool> _shouldShowSecondTutorialStepNotifier =
      ValueNotifier(false);
  bool _pendingSecondTutorial = false;
  final GlobalKey _firstCategoryKey = GlobalKey();
  final GlobalKey _locationButtonKey = GlobalKey();
  final GlobalKey _describirServicioKey = GlobalKey();
  final GlobalKey _describirServicioDetalladoPhotosKey = GlobalKey();
  final GlobalKey _describirServicioDetalladoVoiceKey = GlobalKey();

  TutorialCoachMark? _tutorialCoachMark;
  final List<TargetFocus> _targets = [];
  StreamSubscription<Set<UserModel>>? _userStreamSubscription;

  final ValueNotifier<bool> _isSearchingAnimationActive = ValueNotifier(false);
  final ValueNotifier<Offset?> _animationPositionNotifier = ValueNotifier(null);

  AnimationController? _zoomAnimationController;
  Animation<double>? _zoomAnimation;

  final ValueNotifier<LocationBannerState> _locationBannerStateNotifier =
      ValueNotifier(LocationBannerState.hidden);

  late EnhancedLocationService _locationService;

  bool _isTutorialShown = false;

  final ValueNotifier<bool> _shouldShowContentTop = ValueNotifier(true);

  StreamSubscription<Set<PropuestaModel>>? _propuestaSubscription;
  final Map<String, PropuestaModel> _propuestaPorWorker = {};

  late final VoidCallback _serviceIdListener;

  final ValueNotifier<List<MarkerWithProposal>> _markersWithProposalsNotifier =
      ValueNotifier([]);
  Timer? _screenPositionUpdateTimer;

  final ValueNotifier<bool> _shouldShowProposalMarker = ValueNotifier(true);

  @override
  void initState() {
    super.initState();

    _locationService = EnhancedLocationService();
    _setupLocationListener();
    _initializeLocationService();
    _loadMarkerIcon();
    _loadProviderMarkerIcon();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListener();
    });

    _serviceIdListener = () {
      final serviceId = UserPreferences.activeServiceId.value;
      if (serviceId != null && serviceId.isNotEmpty) {
        _suscribirseAPropuestas(serviceId);
      }
    };

    UserPreferences.activeServiceId.addListener(_serviceIdListener);
  }

  void _suscribirseAPropuestas(String serviceId) {
    _propuestaSubscription = PropuestaRepository.instance
        .getAllPropuestasForService(serviceId)
        .listen((propuestas) {
          for (final p in propuestas) {
            _propuestaPorWorker[p.workerId] = p;
          }
          _updateMarkers();
        });
  }

  Future<void> _initializeLocationService() async {
    await _locationService.initialize();
    _setupLocation();
  }

  void _setupLocationListener() {
    _locationService.addListener(_onLocationStateChanged);
  }

  void _onLocationStateChanged() {
    if (!mounted) return;
    final state = _locationService.currentState;

    LocationBannerState newBannerState;

    if (_locationService.shouldShowNotFoundBanner) {
      newBannerState = LocationBannerState.notFound;
    } else if (_locationService.shouldShowSearchingBanner) {
      newBannerState = LocationBannerState.searching;
    } else {
      newBannerState = LocationBannerState.hidden;
    }

    if (_locationBannerStateNotifier.value != newBannerState) {
      _locationBannerStateNotifier.value = newBannerState;
    }

    if (state == LocationState.found &&
        _locationService.currentPosition != null) {
      final pos = _locationService.currentPosition!;

      _currentPositionNotifier.value = LatLng(pos.latitude, pos.longitude);
      _updateMarkers();

      if (!_isZoomedIn) {
        _isZoomedIn = true;
        _animateCameraBasedOnZoomState();
      }

      if (mapController != null && !_isTutorialShown) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _checkAndShowTutorial();
            _isTutorialShown = true;
          }
        });
      }
    }
  }

  void _setupLocation() async {
    final state = _locationService.currentState;
    if (state == LocationState.serviceDisabled) {
      _locationBannerStateNotifier.value = LocationBannerState.notFound;
    }
  }

  void _animateMapZoomOut(LatLng center) {
    if (mapController == null) return;

    _zoomAnimationController?.dispose();

    _zoomAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(
      begin: _zoomLevelClose,
      end: _zoomLevelFar,
    ).animate(
      CurvedAnimation(
        parent: _zoomAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    _activeProgrammaticOperationId =
        'smooth_zoom_out_${DateTime.now().millisecondsSinceEpoch}';
    _movementController.startProgrammaticMove(_activeProgrammaticOperationId!);

    _zoomAnimationController!.addListener(() async {
      if (mounted) {
        mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: center, zoom: _zoomAnimation!.value),
          ),
        );
      }

      if (_isSearchingAnimationActive.value) {
        _shouldShowContentTop.value = false;
        try {
          final screenCoordinate = await mapController!.getScreenCoordinate(
            center,
          );
          final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

          _animationPositionNotifier.value = Offset(
            screenCoordinate.x / devicePixelRatio,
            screenCoordinate.y / devicePixelRatio,
          );
        } catch (e) {
          debugPrint("Error recalculando la coordenada en el listener: $e");
        }
      }
    });

    _zoomAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          _zoomAnimationController?.dispose();
          _zoomAnimationController = null;
          _zoomAnimation = null;
        }
      }
    });

    _zoomAnimationController!.forward();
  }

  Future<void> _startSearchProcess() async {
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition == null) return;

    _isSearchingAnimationActive.value = true;

    _animateMapZoomOut(currentPosition);
  }

  void _handleSolicitarServicio(bool? shouldStart) {
    if (shouldStart ?? false) {
      _startSearchProcess();
    }
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onMapLoaded(true);

        if (_locationService.currentState == LocationState.found &&
            _locationService.currentPosition != null) {
          if (mapController != null && !_isTutorialShown) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _checkAndShowTutorial();
                _isTutorialShown = true;
              }
            });
          }
        }
      }
    });
  }

  void _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialMostrado = prefs.getBool('tutorial_mostrado') ?? false;

    if (!tutorialMostrado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstTutorialStep();
        prefs.setBool("tutorial_mostrado", true);
      });
    }
  }

  void _loadMarkerIcon() async {
    try {
      _locationMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(26, 26)),
        'assets/icons/ic_location_red.png',
      );
      _updateMarkers();
    } catch (e) {
      debugPrint('Error cargando icono: $e');
      _locationMarkerIcon = BitmapDescriptor.defaultMarker;
      _updateMarkers();
    }
  }

  void _onLocationPermissionTap() {
    final state = _locationService.currentState;
    if (state == LocationState.serviceDisabled) {
      _locationService.requestLocationService();
    } else if (state == LocationState.permissionDenied) {
      _locationService.requestLocationPermission();
    }
  }

  void _onSearchCancel() {
    _locationBannerStateNotifier.value = LocationBannerState.hidden;
  }

  void _onBannerDismiss() {
    _locationBannerStateNotifier.value = LocationBannerState.hidden;
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
    if (mapController == null) return;

    _activeProgrammaticOperationId =
        'zoom_toggle_${DateTime.now().millisecondsSinceEpoch}';
    _movementController.startProgrammaticMove(_activeProgrammaticOperationId!);
    final currentPosition = _currentPositionNotifier.value;
    if (currentPosition == null) {
      _movementController.endProgrammaticMove(_activeProgrammaticOperationId!);
      _activeProgrammaticOperationId = null;
      return;
    }
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPosition,
          zoom: _zoomLevelClose,
          bearing: 0.0,
          tilt: 0.0,
        ),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _getCurrentLocation({bool forceUpdate = false}) async {
    try {
      if (_locationService.currentState != LocationState.found) {
        await _locationService.retryLocation();
        return;
      }

      final position = _locationService.currentPosition;
      if (position != null) {
        final newPosition = LatLng(position.latitude, position.longitude);
        bool shouldUpdate =
            forceUpdate ||
            _currentPositionNotifier.value == null ||
            _calculateDistance(_currentPositionNotifier.value!, newPosition) >
                5;

        if (shouldUpdate) {
          _currentPositionNotifier.value = newPosition;
          _updateMarkers();
          if (forceUpdate) _isZoomedIn = true;
          _animateCameraBasedOnZoomState();
        }
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

  void _updateMarkers() async {
    final currentPosition = _currentPositionNotifier.value;
    Set<Marker> newMarkers = {};
    List<MarkerWithProposal> markersWithProposals = [];

    if (currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentPosition,
          icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 2,
          onTap: _animateCameraBasedOnZoomState,
        ),
      );
    }

    for (var provider in _currentProvidersNotifier.value) {
      final markerId = MarkerId('provider_${provider.uid}');
      final propuesta = _propuestaPorWorker[provider.uid];
      final hasPropuesta = propuesta != null;

      newMarkers.add(
        Marker(
          markerId: markerId,
          position: LatLng(provider.latitud!, provider.longitud!),
          icon:
              _providerMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 1.0),
          zIndexInt: 1,
          onTap: () {
            //_selectedProviderNotifier.value = provider;
            if (hasPropuesta) {
              final updatedProvider = provider.copyWith(propuesta: propuesta);
              _selectedProviderNotifier.value = updatedProvider;
              _selectedProviderNotifier.value?.propuesta = propuesta;
              _isSheetVisibleDetalleProveedorNotifier.value = true;
            }
            _currentlyOpenInfoWindowMarkerId = markerId;
          },
        ),
      );

      if (hasPropuesta) {
        markersWithProposals.add(
          MarkerWithProposal(
            markerId: 'provider_${provider.uid}',
            position: LatLng(provider.latitud!, provider.longitud!),
            price: propuesta.precio.toStringAsFixed(2),
            rating: provider.calificacion.toString(),
          ),
        );
      }
    }

    _markersNotifier.value = newMarkers;
    _markersWithProposalsNotifier.value = markersWithProposals;
    _updateScreenPositions();
  }

  void _updateScreenPositions() async {
    if (mapController == null || _markersWithProposalsNotifier.value.isEmpty) {
      return;
    }

    List<MarkerWithProposal> updatedMarkers = [];

    for (var markerWithProposal in _markersWithProposalsNotifier.value) {
      try {
        final screenCoordinate = await mapController!.getScreenCoordinate(
          markerWithProposal.position,
        );

        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final screenPosition = Offset(
          screenCoordinate.x / devicePixelRatio,
          screenCoordinate.y / devicePixelRatio - 60,
        );

        updatedMarkers.add(
          markerWithProposal.copyWith(screenPosition: screenPosition),
        );
      } catch (e) {
        debugPrint('Error calculando posición de pantalla: $e');
        updatedMarkers.add(markerWithProposal);
      }
    }

    if (mounted) {
      _markersWithProposalsNotifier.value = updatedMarkers;
    }
  }

  void _startScreenPositionUpdates() {
    _screenPositionUpdateTimer?.cancel();
    _screenPositionUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (_) => _updateScreenPositions(),
    );
  }

  void _stopScreenPositionUpdates() {
    _screenPositionUpdateTimer?.cancel();
  }

  // Future<BitmapDescriptor> getProviderIconXCategory(String iconPath) async {
  //   try {
  //     _providerMarkerIcon = await BitmapDescriptor.asset(
  //       ImageConfiguration(
  //         devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
  //         size: const Size(24, 24),
  //       ),
  //       iconPath,
  //     );
  //   } catch (e) {
  //     debugPrint('Error cargando icono de proveedor: $e');
  //     _providerMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
  //       BitmapDescriptor.hueBlue,
  //     );
  //   }

  //   return _providerMarkerIcon ??
  //       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  // }

  void _onCategorySelected(int index) async {
    //_changeOnCategorySelected(index);
    if (_isSolicitudGuardadaNotifier.value &&
        index != _selectedCategoryIndex.value) {
      bool? confirmarCambio = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColor.bgCard,
            title: const Text(
              "Cambiar Categoria",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              "Ya hay una solicitud guardada con una categoría seleccionada. "
              "¿Estás seguro de que deseas cambiar la categoría? Esto eliminará la solicitud actual.",
              style: TextStyle(color: AppColor.txtBooking),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: AppColor.btnColor),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  "Si, cambiar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (confirmarCambio != true) return;
      UserPreferences.activeServiceId.value = null;
      UserPreferences.activeServiceId.removeListener(_serviceIdListener);
      _propuestaSubscription?.cancel();
      _propuestaPorWorker.clear();
      _updateMarkers();

      _datosSolicitudGuardadaNotifier.value = null;
      _isSolicitudGuardadaNotifier.value = false;
      _isProveedorAgregadoNotifier.value = false;
      _selectedProviderNotifier.value = null;
      _proveedoresSeleccionadosNotifier.value = [];

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Categoria cambiada exitosamente",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    _selectedCategoryIndex.value = index;
    _categoriaErrorNotifier.value = false;

    if (index >= 0 && index < CategoryMock.getCategories().length) {
      String selectedCategory = CategoryMock.getCategories()[index].name;
      _userStreamSubscription?.cancel();

      _userStreamSubscription = UserRepository.instance
          .findByCategoryStream(selectedCategory)
          .listen((providers) {
            _currentProvidersNotifier.value = providers;

            if (_shouldShowSecondTutorialStepNotifier.value &&
                providers.isNotEmpty) {
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
          });
    } else {
      _userStreamSubscription?.cancel();
      _currentProvidersNotifier.value = {};
      _updateMarkers();
    }

    UserPreferences.activeServiceId.addListener(_serviceIdListener);
  }

  void _adjustCameraToShowAllMarkers() {
    if (_currentProvidersNotifier.value.isEmpty || mapController == null) {
      return;
    }

    Set<UserModel> providers = _currentProvidersNotifier.value;
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

    mapController!.animateCamera(
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
    if (_currentlyOpenInfoWindowMarkerId != null && mapController != null) {
      mapController!.hideMarkerInfoWindow(_currentlyOpenInfoWindowMarkerId!);
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
      _shouldShowProposalMarker.value = false;
      _startScreenPositionUpdates();
    }
    _mapInteractionTimer?.cancel();
    _mapInteractionTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && _isMapBeingMoved) {
        _isMapBeingMoved = false;
      }
    });
  }

  void _onCameraIdle() {
    _stopScreenPositionUpdates();
    _updateScreenPositions();
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
        _shouldShowProposalMarker.value = true;
      }
    });
  }

  Future<void> _attemptToShowMarkersTutorial() async {
    if (_hasShownMarkerTutorialNotifier.value ||
        _currentProvidersNotifier.value.isEmpty ||
        !mounted ||
        mapController == null) {
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
        final screenCoordinate = await mapController!.getScreenCoordinate(
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
      enableTargetTab: false,
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
                      backgroundColor: const Color.fromRGBO(56, 109, 243, 1),
                      padding: const EdgeInsets.all(8),
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
        Future.delayed(const Duration(seconds: 1), _showFourthTutorialStep);
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
      //textSkip: "FINALIZAR",
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      // onFinish: () => _marcarTutorialComoMostrado(),
      // onSkip: () {
      //   _marcarTutorialComoMostrado();
      //   return true;
      // },
    )..show(context: context);
  }

  void _showFifthTutorialStep() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "describir-servicio-detallado-photos-key",
        keyTarget: _describirServicioDetalladoPhotosKey,
        shape: ShapeLightFocus.RRect,
        enableTargetTab: false,
        radius: 10,
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
                    "Agrega mas detalles",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Puedes agregar fotos o videos para que el proveedor tenga mas detalles",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _tutorialCoachMark?.finish();
                        _showSixthTutorialStep();
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Siguiente",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(56, 109, 243, 1),
                        padding: const EdgeInsets.all(8),
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
      ),
    );
    _tutorialCoachMark = TutorialCoachMark(
      targets: _targets,
      //onClickTarget: (target) => _requestService(),
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(context: context);
  }

  void _showSixthTutorialStep() {
    _targets.clear();
    _targets.add(
      TargetFocus(
        identify: "describir-servicio-detallado-voice-key",
        keyTarget: _describirServicioDetalladoVoiceKey,
        shape: ShapeLightFocus.Circle,
        radius: 10,
        enableTargetTab: false,
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
                    "¿No quieres escribir? Usa el micrófono",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Mantén presionado este ícono para grabar",
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
      textSkip: "FINALIZAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => _marcarTutorialComoMostrado(),
      onSkip: () {
        _marcarTutorialComoMostrado();
        return true;
      },
    )..show(context: context);
  }

  Future<void> _marcarTutorialComoMostrado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_mostrado', true);
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Proveedores en el Mapa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Aun no hay proveedores disponibles en el mapa para esta categoría",
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
                SizedBox(height: 20),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton.icon(
                //     onPressed: () {
                //       _tutorialCoachMark?.finish();
                //       _showLocationButtonTutorial();
                //     },
                //     icon: const Icon(Icons.arrow_forward, color: Colors.white),
                //     label: const Text(
                //       "Siguiente",
                //       style: TextStyle(color: Colors.white),
                //     ),
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       minimumSize: const Size(0, 0),
                //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     ),
                //   ),
                // ),
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
    Future.delayed(const Duration(seconds: 1), _showFifthTutorialStep);
  }

  void _handleSheetDismissedSolicitarServicio() {
    if (mounted) {
      _isSheetVisibleSolicitarServicioNotifier.value = false;
    }
  }

  void _manejarGuardadoDesdeSheetDetallado(ServiceModel data) {
    if (mounted) {
      _datosSolicitudGuardadaNotifier.value = data;
      _isSolicitudGuardadaNotifier.value = true;
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

  // void _isSolicitudServicioOnTapped(bool? isSolicitarServicio) {
  //   _isTappedSolicitarServicioNotifier.value = isSolicitarServicio ?? false;
  //   if (_isTappedSolicitarServicioNotifier.value) {
  //     _updateMarkers();
  //   }
  // }

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
  //     _isSolicitudGuardadaNotifier.value = false;127.0.0.1:6555
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

    return ValueListenableBuilder<LocationBannerState>(
      valueListenable: _locationBannerStateNotifier,
      builder: (context, bannerState, _) {
        return LocationBannerController(
          bannerState: bannerState,
          onLocationPermissionTap: _onLocationPermissionTap,
          onSearchCancel: _onSearchCancel,
          onBannerDismiss: _onBannerDismiss,
          child: Stack(
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

              ValueListenableBuilder<bool>(
                valueListenable: _shouldShowProposalMarker,
                builder: (context, showProposalMarker, child) {
                  if (!showProposalMarker) return const SizedBox.shrink();
                  return ValueListenableBuilder<List<MarkerWithProposal>>(
                    valueListenable: _markersWithProposalsNotifier,
                    builder: (context, markersWithProposals, _) {
                      return Stack(
                        children:
                            markersWithProposals
                                .where(
                                  (marker) => marker.screenPosition != null,
                                )
                                .map(
                                  (marker) => Positioned(
                                    left: marker.screenPosition!.dx - 30,
                                    top: marker.screenPosition!.dy - 12,
                                    child: IgnorePointer(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ProposalMarkerWidget(
                                            price: marker.price,
                                            rating: marker.rating,
                                          ),
                                          CustomPaint(
                                            size: const Size(20, 15),
                                            painter: BalloonTailPainter(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      );
                    },
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isSearchingAnimationActive,
                builder: (context, isActive, child) {
                  if (isActive) return const SizedBox.shrink();
                  return Positioned(
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
                                          (category) =>
                                              _onCategorySelected(category),
                                    ),
                                  ),
                                  if (hasError)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Selecciona una categoria",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isSearchingAnimationActive,
                builder: (context, isActive, child) {
                  if (isActive) return const SizedBox.shrink();
                  return Positioned(
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
                  );
                },
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
                    child: ValueListenableBuilder<Set<UserModel>>(
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
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _isSolicitudGuardadaNotifier,
                                builder: (context, isGuardada, child) {
                                  return ValueListenableBuilder<ServiceModel?>(
                                    valueListenable:
                                        _datosSolicitudGuardadaNotifier,
                                    builder: (context, datosGuardados, _) {
                                      return DraggableSheetSolicitarServicio(
                                        detallarServicioKey:
                                            _describirServicioKey,
                                        targetInitialSize: 0.21,
                                        minSheetSize: 0.21,
                                        maxSheetSize: 0.21,
                                        snapPoints: const [0.35],
                                        onTapPressed: () {
                                          if (_selectedCategoryIndex.value ==
                                              -1) {
                                            _categoriaErrorNotifier.value =
                                                true;
                                            return;
                                          }
                                          _requestService();
                                        },
                                        onCategoriaError:
                                            () =>
                                                _categoriaErrorNotifier.value =
                                                    true,
                                        categoriaError:
                                            _categoriaErrorNotifier.value,
                                        selectedCategoryIndex:
                                            _selectedCategoryIndex.value,
                                        onAbrirDetallesPressed:
                                            (
                                              isVisible,
                                            ) => _abrirSheetDetalladoDesdeSheet2(
                                              isSheetVisibleSolicitarServicio:
                                                  isVisible,
                                            ),
                                        datosSolicitudExistente: datosGuardados,
                                        onProveedores: proveedores,
                                        isSolicitudGuardada: isGuardada,
                                        onPressedSolicitarServicio:
                                            _handleSolicitarServicio,
                                        //_isSolicitudServicioOnTapped,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            ValueListenableBuilder<bool>(
                              valueListenable: _isSearchingAnimationActive,
                              builder: (context, isActive, child) {
                                if (!isActive) return const SizedBox.shrink();

                                return ValueListenableBuilder<Offset?>(
                                  valueListenable: _animationPositionNotifier,
                                  builder: (context, position, _) {
                                    if (position == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return Positioned(
                                      left: position.dx - 60,
                                      top: position.dy - 60,
                                      child: AnimationHome(
                                        onAnimationComplete: () {
                                          _isSearchingAnimationActive.value =
                                              false;
                                          _animationPositionNotifier.value =
                                              null;
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
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
                      globalKeyServicioDetalladoPhotos:
                          _describirServicioDetalladoPhotosKey,
                      globalKeyServicioDetalladoVoice:
                          _describirServicioDetalladoVoiceKey,
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
                      // isSolicitudEnviada:
                      //     (isEnviada) =>
                      //         _isSolicitudGuardadaNotifier.value = isEnviada,
                    ),
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isSearchingAnimationActive,
                builder: (context, isActive, child) {
                  if (isActive) {
                    return Positioned(
                      bottom: 40,
                      right: 50,
                      left: 50,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          backgroundColor: AppColor.bgVerification,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Cancelar Solicitud",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                    );
                  }

                  return ValueListenableBuilder<bool>(
                    valueListenable: _isSheetVisibleDetalleProveedorNotifier,
                    builder: (context, isVisible, _) {
                      if (!isVisible) return const SizedBox.shrink();
                      return Positioned.fill(
                        child: Stack(
                          children: [
                            ModalBarrier(
                              color: Colors.black.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              dismissible: true,
                              onDismiss: _handleSheetDismissedDetalleProveedor,
                            ),
                            Positioned.fill(
                              child: ValueListenableBuilder<UserModel?>(
                                valueListenable: _selectedProviderNotifier,
                                builder: (context, selectedProvider, _) {
                                  return ValueListenableBuilder(
                                    valueListenable: _currentPositionNotifier,
                                    builder: (context, positionClient, _) {
                                      return DraggableSheetDetalleProveedor(
                                        targetInitialSize: 0.55,
                                        minSheetSize: 0.0,
                                        maxSheetSize: 0.95,
                                        snapPoints: const [0.0, 0.55, 0.95],
                                        onDismiss:
                                            _handleSheetDismissedDetalleProveedor,
                                        //onProveedorAgregado: _agregarProveedor,
                                        selectedProvider: selectedProvider,
                                        clientPosition: positionClient,
                                        isProveedorAgregado:
                                            (isAgregado) =>
                                                _isProveedorAgregadoNotifier
                                                    .value = isAgregado,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
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
    _userStreamSubscription?.cancel();
    _isSearchingAnimationActive.dispose();
    _animationPositionNotifier.dispose();
    _zoomAnimationController?.dispose();
    _screenPositionUpdateTimer?.cancel();
    _markersWithProposalsNotifier.dispose();
    _propuestaSubscription?.cancel();
    UserPreferences.activeServiceId.removeListener(_serviceIdListener);
    super.dispose();
  }
}
