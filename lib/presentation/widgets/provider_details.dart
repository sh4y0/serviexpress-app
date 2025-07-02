import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/propuesta_model.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/repositories/propuesta_repository.dart';
import 'package:serviexpress_app/data/service/google_maps_service.dart';
import 'package:serviexpress_app/data/service/location_service.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/widgets/audio_item.dart';
import 'package:serviexpress_app/presentation/widgets/video_item.dart';

class ProviderDetails extends StatefulWidget {
  final ServiceComplete service;
  final String? mapStyle;
  final LatLng? position;

  const ProviderDetails({
    super.key,
    required this.service,
    required this.mapStyle,
    this.position,
  });

  @override
  State<ProviderDetails> createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
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
    final providerPosition = widget.position;
    final clientData = widget.service.cliente;
    final clientPosition =
        (clientData.latitud != null && clientData.longitud != null)
            ? LatLng(clientData.latitud!, clientData.longitud!)
            : null;

    if (providerPosition == null || clientPosition == null) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _fitRouteOnMap(providerPosition, clientPosition);

    _drawMarkers(providerPosition, clientPosition);

    _fullRoutePoints = await _mapsService.getDirections(
      providerPosition,
      clientPosition,
    );

    if (_fullRoutePoints.isNotEmpty) {
      _startPolylineAnimation();
    } else {
      _drawFallbackLine(providerPosition, clientPosition);
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
        markerId: MarkerId('client_${widget.service.cliente.uid}'),
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
    final serviceData = widget.service.service;

    final bool hayMultimedia =
        (serviceData.fotos?.isNotEmpty ?? false) ||
        (serviceData.videos?.isNotEmpty ?? false) ||
        (serviceData.audios?.isNotEmpty ?? false);

    final double minSheetSize = hayMultimedia ? 0.30 : 0.3;
    final double maxSheetSize = hayMultimedia ? 0.8 : 0.63;

    final mediaQuery = MediaQuery.of(context);
    final double topPaddingHeight = 60.0 + 25.0 + mediaQuery.padding.top;
    final double bottomSheetInitialHeight = mediaQuery.size.height * 0.34;

    return Scaffold(
      extendBodyBehindAppBar: true,
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

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 10,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColor.bgBack,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(2, 0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: minSheetSize,
            maxChildSize: maxSheetSize,
            builder: (context, scrollController) {
              return SafeArea(
                top: true,
                child: ScreenClientData(
                  service: widget.service,
                  scrollController: scrollController,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ScreenClientData extends StatefulWidget {
  const ScreenClientData({
    super.key,
    required this.service,
    required this.scrollController,
  });

  final ServiceComplete service;
  final ScrollController scrollController;

  @override
  State<ScreenClientData> createState() => _ScreenClientDataState();
}

class _ScreenClientDataState extends State<ScreenClientData> {
  String? presupuestoPersonalizado;
  String? propuestaTexto;

  // bool isVideoUrl(String url) {
  //   final uri = Uri.tryParse(url);
  //   if (uri == null) return false;

  //   final path = uri.path.toLowerCase();
  //   return path.endsWith(".mp4") ||
  //       url.contains(".mov") ||
  //       url.contains(".avi");
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              margin: const EdgeInsets.only(bottom: 15, left: 80, right: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColor.dotColor,
              ),
            ),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                shrinkWrap: true,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child:
                                    widget.service.cliente.imagenUrl != null
                                        ? FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/images/avatar.png",
                                          image:
                                              widget.service.cliente.imagenUrl!,
                                          fit: BoxFit.cover,
                                          imageErrorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.asset(
                                              "assets/images/avatar.png",
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                        : Image.asset(
                                          "assets/images/avatar.png",
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColor.bgStr),
                              const SizedBox(width: 4),
                              Text(
                                widget.service.cliente.calificacion.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FutureBuilder<List<String>>(
                          future: Future.wait([
                            LocationService.getAddressFromLatLng(
                              widget.service.cliente.latitud!,
                              widget.service.cliente.longitud!,
                            ),
                            LocationService.getDistanceFromCurrentLocation(
                              widget.service.cliente.latitud!,
                              widget.service.cliente.longitud!,
                            ),
                          ]),
                          builder: (context, snapshot) {
                            final direccion =
                                snapshot.hasData
                                    ? snapshot.data![0]
                                    : "Obteniendo dirección...";
                            final distancia =
                                snapshot.hasData
                                    ? snapshot.data![1]
                                    : "Calculando distancia...";

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.service.cliente.nombreCompleto,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_location.svg",
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        maxLines: 2,
                                        direccion,
                                        style: const TextStyle(
                                          color: AppColor.txtPrice,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_distance.svg",
                                      width: 23,
                                      height: 23,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        distancia,
                                        style: const TextStyle(
                                          color: AppColor.bgDistance,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: AppColor.txtPrice,
                      //     borderRadius: BorderRadius.circular(50),
                      //   ),
                      //   child: IconButton(
                      //     onPressed: () {},
                      //     icon: SvgPicture.asset(
                      //       "assets/icons/ic_gochat.svg",
                      //       width: 25,
                      //       height: 25,
                      //     ),
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.bgMsgUser,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detalles de servicios",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.service.service.descripcion,
                          style: const TextStyle(color: AppColor.txtBooking),
                        ),
                      ],
                    ),
                  ),

                  if (widget.service.service.fotos != null &&
                      widget.service.service.fotos!.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.service.service.fotos!.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              final photos = widget.service.service.fotos!;
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 175,
                                    ),
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: PageView.builder(
                                          controller: PageController(
                                            initialPage: index,
                                          ),
                                          itemCount: photos.length,
                                          itemBuilder: (context, pageIndex) {
                                            return InteractiveViewer(
                                              child: Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    photos[pageIndex],
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        "assets/images/img_services.png",
                                                        fit: BoxFit.contain,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.service.service.fotos![index],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/img_services.png",
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  if (widget.service.service.videos != null &&
                      widget.service.service.videos!.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.service.service.videos!.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final url = widget.service.service.videos![index];
                          if (url.isEmpty) {
                            return Image.asset(
                              "assets/images/img_services.png",
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            );
                          }
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child: VideoItem(url: url),
                          );
                        },
                      ),
                    ),
                  ],

                  if (widget.service.service.audios != null &&
                      widget.service.service.audios!.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: widget.service.service.audios!.length,
                        itemBuilder: (context, index) {
                          final audioUrl =
                              widget.service.service.audios![index];
                          return audioUrl.isEmpty
                              ? const SizedBox(
                                width: 200,
                                child: Center(
                                  child: Text(
                                    "Audio Vacío",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              : AudioItem(url: audioUrl);
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    "Ingresa el precio:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  InputPresupuestoLauncher(
                    presupuesto: presupuestoPersonalizado,
                    onTap: () async {
                      final result = await mostrarPropuesta(
                        context,
                        initialValue: presupuestoPersonalizado,
                        initialpropuesta: propuestaTexto,
                      );
                      if (result != null) {
                        setState(() {
                          presupuestoPersonalizado = result["presupuesto"];
                          propuestaTexto = result["propuesta"];
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.bgMsgUser,
                      ),
                      child: const Text(
                        "No me interesa",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        final precio = presupuestoPersonalizado ?? '';
                        final description = propuestaTexto ?? '';
                        if (precio.isEmpty || description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Completa todos los campos antes de enviar',
                              ),
                            ),
                          );
                          return;
                        }
                        final workerId = await UserPreferences.getUserId();
                        if (workerId == null) return;
                        final propuesta = PropuestaModel(
                          id:
                              PropuestaRepository.instance
                                  .generatePropuestaId(),
                          serviceId: widget.service.service.id,
                          workerId: workerId,
                          clientId: widget.service.cliente.uid,
                          precio: double.tryParse(precio) ?? 0.0,
                          descripcion: description,
                        );

                        await PropuestaRepository.instance.createPropuesta(
                          propuesta,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Propuesta enviada exitosamente",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFF101328),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.btnColor,
                      ),
                      child: const Text(
                        "Enviar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputPresupuesto extends StatefulWidget {
  final String? initialValue;
  final String? initialpropuesta;
  const InputPresupuesto({super.key, this.initialValue, this.initialpropuesta});

  @override
  State<InputPresupuesto> createState() => _InputPresupuestoState();
}

class _InputPresupuestoState extends State<InputPresupuesto> {
  late final TextEditingController _controller;
  late final TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
    _descripcionController = TextEditingController(
      text: widget.initialpropuesta ?? "",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  "Crear propuesta",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Precio",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17.5,
                ),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.colorInput,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  "S/",
                  style: TextStyle(color: AppColor.txtBooking, fontSize: 17),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      borderSide: BorderSide(
                        color: AppColor.colorInput,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      borderSide: BorderSide(
                        color: AppColor.bgMsgUser,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Propuesta",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Describe detalladamente el servicio que ofrecerás",
            style: TextStyle(color: AppColor.txtBooking),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descripcionController,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColor.colorInput,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColor.bgMsgUser,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isEmpty) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: AppColor.bgMsgClient,
                        icon: const Icon(
                          Icons.error_outline_outlined,
                          color: Colors.red,
                          size: 50,
                        ),
                        title: const Text("Campo Obligatorio"),
                        content: const Text(
                          "Por favor ingresa un valor para el presupuesto.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );
                return;
              }
              Navigator.of(context).pop({
                "presupuesto": _controller.text,
                "propuesta": _descripcionController.text,
              });
            },
            child: const Text(
              "Crear Propuesta",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class InputPresupuestoLauncher extends StatelessWidget {
  final VoidCallback onTap;
  final String? presupuesto;

  const InputPresupuestoLauncher({
    super.key,
    required this.onTap,
    this.presupuesto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17.5,
                ),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.colorInput,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  "S/",
                  style: TextStyle(color: AppColor.txtBooking, fontSize: 17),
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: presupuesto),
                    style: const TextStyle(
                      color: AppColor.txtBooking,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.edit, color: Colors.white),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        borderSide: BorderSide(
                          color: AppColor.bgMsgUser,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        borderSide: BorderSide(
                          color: AppColor.colorInput,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<Map<String, String>?> mostrarPropuesta(
  BuildContext context, {
  String? initialValue,
  String? initialpropuesta,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: SingleChildScrollView(
          child: Dialog(
            backgroundColor: AppColor.bgCreate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            insetPadding: EdgeInsets.zero,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: InputPresupuesto(
                initialValue: initialValue,
                initialpropuesta: initialpropuesta,
              ),
            ),
          ),
        ),
      );
    },
  );
}
