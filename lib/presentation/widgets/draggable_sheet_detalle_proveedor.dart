import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/mock_reviews.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/review_keys.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/draggable_sheet_detail_provider_string.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/route_argument_key.dart';

class DraggableSheetDetalleProveedor extends StatefulWidget {
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;
  final Function(UserModel)? onProveedorAgregado;
  final UserModel? selectedProvider;
  final Function(bool)? isProveedorAgregado;
  final LatLng? clientPosition;
  final bool showPropuesta;

  const DraggableSheetDetalleProveedor({
    super.key,
    this.onDismiss,
    required this.targetInitialSize,
    this.minSheetSize = 0.0,
    this.maxSheetSize = 0.95,
    required this.snapPoints,
    this.entryAnimationDuration = const Duration(milliseconds: 200),
    this.entryAnimationCurve = Curves.easeOutCubic,
    this.onProveedorAgregado,
    this.selectedProvider,
    this.isProveedorAgregado,
    this.clientPosition,
    this.showPropuesta = true,
  });
  @override
  State<DraggableSheetDetalleProveedor> createState() =>
      _DraggableSheetDetalleProveedorState();
}

class _DraggableSheetDetalleProveedorState
    extends State<DraggableSheetDetalleProveedor> {
  final sheetKeyInDraggable = GlobalKey();
  late DraggableScrollableController _internalController;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _internalController = DraggableScrollableController();
    _internalController.addListener(_onChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _internalController.isAttached) {
        _internalController.animateTo(
          widget.targetInitialSize,
          duration: widget.entryAnimationDuration,
          curve: widget.entryAnimationCurve,
        );
      }
    });
  }

  @override
  void dispose() {
    _internalController.removeListener(_onChanged);
    _internalController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_internalController.isAttached) return;

    final currentSize = _internalController.size;
    if (!_isDismissing && currentSize <= widget.minSheetSize + 0.01) {
      _isDismissing = true;
      widget.onDismiss?.call();
    } else if (currentSize > widget.minSheetSize + 0.01) {
      _isDismissing = false;
    }
  }

  void collapse() {
    final targetSnap = widget.snapPoints.firstWhere(
      (s) => s > widget.minSheetSize,
      orElse: () => widget.targetInitialSize,
    );
    _animatedSheet(targetSnap);
  }

  void anchor() {
    _animatedSheet(widget.snapPoints.last);
  }

  void expand() {
    _animatedSheet(widget.maxSheetSize);
  }

  void hide() {
    if (_internalController.isAttached) {
      _isDismissing = true;
      _internalController
          .animateTo(
            widget.minSheetSize,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInCubic,
          )
          .whenComplete(() {
            if (mounted &&
                _internalController.size <= widget.minSheetSize + 0.01) {
              widget.onDismiss?.call();
            } else if (mounted) {
              _isDismissing = false;
            }
          });
    }
  }

  void _animatedSheet(double size) {
    if (_internalController.isAttached) {
      _internalController.animateTo(
        size,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  // void _agregarProveedor() {
  //   final proveedor = UserModel(
  //     uid: widget.selectedProvider!.uid,
  //     nombres: widget.selectedProvider!.nombres,
  //     calificacion: widget.selectedProvider?.calificacion,
  //     especialidad: widget.selectedProvider!.especialidad,
  //     descripcion: widget.selectedProvider?.descripcion,
  //     imagenUrl: widget.selectedProvider?.imagenUrl,
  //     username: widget.selectedProvider!.username,
  //     email: widget.selectedProvider!.email,
  //     dni: widget.selectedProvider!.dni,
  //     telefono: widget.selectedProvider!.telefono,
  //     apellidoPaterno: widget.selectedProvider!.apellidoPaterno,
  //     apellidoMaterno: widget.selectedProvider!.apellidoMaterno,
  //     nombreCompleto: widget.selectedProvider!.nombreCompleto,
  //   );
  //   widget.isProveedorAgregado(true);
  //   widget.onProveedorAgregado?.call(proveedor);
  //   hide();
  // }

  @override
  Widget build(BuildContext context) {
    final reviews = MockReviews.all;

    return LayoutBuilder(
      builder: (builder, constraints) {
        return DraggableScrollableSheet(
          key: sheetKeyInDraggable,
          initialChildSize: widget.minSheetSize,
          maxChildSize: widget.maxSheetSize,
          minChildSize: widget.minSheetSize,
          expand: true,
          snap: true,
          snapSizes: widget.snapPoints,
          controller: _internalController,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xff060716),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff060716),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                              horizontal: 26.5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 29.5),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      color: Color.fromRGBO(117, 148, 255, 1),
                                      shape: BoxShape.rectangle,
                                    ),
                                    width: 154,
                                    height: 4,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1B1B2E),
                                      ),
                                      child: ClipOval(
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child:
                                              widget
                                                          .selectedProvider!
                                                          .imagenUrl !=
                                                      null
                                                  ? FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/images/avatar.png",
                                                    image:
                                                        widget
                                                            .selectedProvider!
                                                            .imagenUrl!,
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
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .selectedProvider!
                                                      .nombres,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${widget.selectedProvider!.calificacion}',
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget
                                                          .selectedProvider
                                                          ?.descripcion ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 60,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                236,
                                                244,
                                                255,
                                                1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'S/.${widget.selectedProvider?.propuesta?.precio.toString()}',
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                    42,
                                                    52,
                                                    216,
                                                    1,
                                                  ),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.showPropuesta) ...[
                                  const SizedBox(height: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        DetailProviderString.proposal,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget
                                            .selectedProvider!
                                            .propuesta!
                                            .descripcion,
                                        style: const TextStyle(
                                          color: AppColor.txtDetalle,
                                          fontSize: 14,
                                        ),
                                        maxLines: 6,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 16),

                                //const SizedBox(height: 24),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      DetailProviderString.reviews,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      DetailProviderString.reviewsCount,
                                      style: TextStyle(
                                        color: Color(0xff3d4d8a),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.65,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.separated(
                                          scrollDirection: Axis.vertical,
                                          itemCount: reviews.length,
                                          separatorBuilder:
                                              (context, index) =>
                                                  const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final review = reviews[index];
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0c0d23),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            review[ReviewKeys
                                                                .avatar],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              review[ReviewKeys
                                                                  .name],
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              review[ReviewKeys
                                                                  .subtitle],
                                                              style: const TextStyle(
                                                                color:
                                                                    AppColor
                                                                        .textInput,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            review[ReviewKeys
                                                                    .rating]
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),

                                                  Text(
                                                    review[ReviewKeys.comment],
                                                    style: const TextStyle(
                                                      color: AppColor.textInput,
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26.5,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              if (widget.showPropuesta) {
                                Navigator.pushNamed(context, AppRoutes.chat);
                              } else {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.showSuper,
                                  arguments: {
                                    RouteArgumentKeys.selectedProvider:
                                        widget.selectedProvider,
                                    RouteArgumentKeys.clientPosition:
                                        widget.clientPosition,
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3645f5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            label: Text(
                              widget.showPropuesta
                                  ? DetailProviderString.goToChat
                                  : DetailProviderString.accept,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Alerts.instance.showInfoAlert(
                                context,
                                DetailProviderString.notImplemented,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                141,
                                93,
                                93,
                                93,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            label: Text(
                              widget.showPropuesta
                                  ? DetailProviderString.cancel
                                  : DetailProviderString.notInterested,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
