import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/service/google_maps_service.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/widgets/draggable_sheet_detalle_proveedor.dart';

class ClientDetails extends StatefulWidget {
  final LatLng? clientPosition;
  final String? mapStyle;
  final UserModel? provider;

  const ClientDetails({
    super.key,
    required this.clientPosition,
    required this.mapStyle,
    this.provider,
  });

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  final GoogleMapsService _mapsService = GoogleMapsService();
  final ValueNotifier<Set<Marker>> _markersNotifier = ValueNotifier({});

  static const LatLng _center = LatLng(-8.073506, -79.057020);
  static const double _zoomLevelFar = 14.0;
  //static const double _zoomLevelClose = 16.5;
  final MapMovementController _movementController = MapMovementController();
  final ValueNotifier<bool> _shouldShowSheet = ValueNotifier(true);
  BitmapDescriptor? _locationMarkerIcon;
  BitmapDescriptor? _providerMarkerIcon;

  bool _isMapBeingMoved = false;
  Timer? _mapInteractionTimer;
  GoogleMapController? mapController;

  List<LatLng> _fullRoutePoints = [];
  List<LatLng> _animatedRoutePoints = [];
  Timer? _animationTimer;
  int _currentPointIndex = 0;

  final ValueNotifier<Set<Polyline>> _polylinesNotifier = ValueNotifier({});

  @override
  void initState() {
    super.initState();

    _loadMarkerIcon();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _mapInteractionTimer?.cancel();
    super.dispose();
  }

  void _loadMarkerIcon() async {
    try {
      _locationMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(26, 26)),
        'assets/icons/ic_clean2.png',
      );
      _providerMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(26, 26)),
        'assets/icons/ic_location_red.png',
      );
    } catch (e) {
      debugPrint('Error cargando icono: $e');
      _locationMarkerIcon = BitmapDescriptor.defaultMarker;
      _providerMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadAndAnimateRoute();
  }

  Future<void> _loadAndAnimateRoute() async {
    final latitud = widget.provider?.latitud;
    final longitud = widget.provider?.longitud;

    if (latitud == null || longitud == null) {
      return;
    }

    final providerPosition = LatLng(latitud, longitud);
    final clientPositionDetails = widget.clientPosition;

    if (clientPositionDetails == null) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _fitRouteOnMap(providerPosition, clientPositionDetails);

    _drawMarkers(providerPosition, clientPositionDetails);

    _fullRoutePoints = await _mapsService.getDirections(
      providerPosition,
      clientPositionDetails,
    );

    if (_fullRoutePoints.isNotEmpty) {
      _startPolylineAnimation();
    } else {
      _drawFallbackLine(providerPosition, clientPositionDetails);
    }
  }

  void _drawMarkers(LatLng providerPosition, LatLng clientPosition) {
    Set<Marker> newMarkers = {};
    newMarkers.add(
      Marker(
        markerId: const MarkerId('providerLocation'),
        position: providerPosition,
        icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );
    newMarkers.add(
      Marker(
        markerId: MarkerId('client_${widget.provider!.uid}'),
        position: clientPosition,
        icon: _providerMarkerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );

    _markersNotifier.value = newMarkers;
  }

  void _startPolylineAnimation() {
    _animationTimer?.cancel();
    _animatedRoutePoints = [];
    _currentPointIndex = 0;

    if (_fullRoutePoints.isNotEmpty) {
      _animatedRoutePoints.add(_fullRoutePoints[0]);
    }

    const animationDuration = Duration(milliseconds: 20);

    _animationTimer = Timer.periodic(animationDuration, (timer) {
      if (_currentPointIndex < _fullRoutePoints.length - 1) {
        _currentPointIndex++;
        _animatedRoutePoints.add(_fullRoutePoints[_currentPointIndex]);

        final newPolylines = <Polyline>{};
        newPolylines.add(
          Polyline(
            polylineId: const PolylineId('animated_route'),
            color: const Color.fromRGBO(74, 102, 255, 1),
            width: 3,
            points: _animatedRoutePoints,
            startCap: Cap.squareCap,
            endCap: Cap.squareCap,
          ),
        );
        _polylinesNotifier.value = newPolylines;
      } else {
        timer.cancel();
      }
    });
  }

  void _drawFallbackLine(LatLng p1, LatLng p2) {
    final fallbackPolyline = Polyline(
      polylineId: const PolylineId('fallback_route'),
      color: Colors.red.withAlpha((0.8 * 255).toInt()),
      width: 4,
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      points: [p1, p2],
    );
    _polylinesNotifier.value = {fallbackPolyline};
  }

  void _fitRouteOnMap(LatLng p1, LatLng p2) {
    if (mapController == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        p1.latitude < p2.latitude ? p1.latitude : p2.latitude,
        p1.longitude < p2.longitude ? p1.longitude : p2.longitude,
      ),
      northeast: LatLng(
        p1.latitude > p2.latitude ? p1.latitude : p2.latitude,
        p1.longitude > p2.longitude ? p1.longitude : p2.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 75.0));
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
    _mapInteractionTimer?.cancel();
    _mapInteractionTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _isMapBeingMoved = false;
        _shouldShowSheet.value = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double topPaddingHeight = 60.0 + 25.0 + mediaQuery.padding.top;
    final double bottomSheetInitialHeight = mediaQuery.size.height * 0.34;

    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<Set<Polyline>>(
            valueListenable: _polylinesNotifier,
            builder: (context, polylines, _) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                style: widget.mapStyle,
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: _zoomLevelFar,
                ),
                markers: _markersNotifier.value,
                polylines: polylines,
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

          DraggableSheetDetalleProveedor(
            targetInitialSize: 0.52,
            minSheetSize: 0.52,
            maxSheetSize: 0.95,
            snapPoints: const [0.52, 0.95],
            selectedProvider: widget.provider,
            clientPosition: widget.clientPosition,
            showPropuesta: true,
          ),
        ],
      ),
    );
  }
}
