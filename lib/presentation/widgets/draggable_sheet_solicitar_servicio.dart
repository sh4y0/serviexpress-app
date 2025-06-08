import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';
import 'package:serviexpress_app/presentation/widgets/proveedor_model_card.dart';

class DraggableSheetSolicitarServicio extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;
  final bool isInteractionEnabled;
  final VoidCallback onTapPressed;

  final ServiceModel? datosSolicitudExistente;
  final Function(bool? isSheetVisibleSolicitarServicio) onAbrirDetallesPressed;

  final List<UserModel> proveedoresSeleccionados;
  final Function(UserModel)? onProveedorRemovido;
  final Function(UserModel)? onProveedorTapped;

  final bool isSolicitudGuardada;
  final bool isProveedorAgregado;
  final bool categoriaError;
  final VoidCallback? onCategoriaError;

  final int selectedCategoryIndex;

  const DraggableSheetSolicitarServicio({
    super.key,
    this.onDismiss,
    required this.targetInitialSize,
    this.minSheetSize = 0.0,
    this.maxSheetSize = 0.95,
    required this.snapPoints,
    this.entryAnimationDuration = const Duration(milliseconds: 200),
    this.entryAnimationCurve = Curves.easeOutCubic,
    this.isInteractionEnabled = true,
    required this.onTapPressed,
    required this.onAbrirDetallesPressed,
    this.datosSolicitudExistente,
    required this.proveedoresSeleccionados,
    this.onProveedorRemovido,
    this.onProveedorTapped,
    this.isSolicitudGuardada = false,
    this.isProveedorAgregado = false,
    this.categoriaError = false,
    this.onCategoriaError,
    this.selectedCategoryIndex = -1,
  });
  @override
  ConsumerState<DraggableSheetSolicitarServicio> createState() =>
      DraggableSheetSolicitarServicioState();
}

class DraggableSheetSolicitarServicioState
    extends ConsumerState<DraggableSheetSolicitarServicio> {
  final Logger _log = Logger('DraggableSheetSolicitarServicioState');
  final sheetKeyInDraggable = GlobalKey();
  final FocusNode focusNodePrimero = FocusNode();

  late DraggableScrollableController _internalController;
  late TextEditingController _descripcionController = TextEditingController();

  bool _isDismissing = false;
  bool _descripcionError = false;

  final List<String> proveedoresSeleccionadosId = [];

  @override
  void initState() {
    super.initState();
    _internalController = DraggableScrollableController();
    _internalController.addListener(_onChanged);

    _descripcionController = TextEditingController();

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
      (s) => s >= widget.minSheetSize,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (builder, constraints) {
        return DraggableScrollableSheet(
          key: sheetKeyInDraggable,
          initialChildSize: widget.targetInitialSize,
          maxChildSize: widget.maxSheetSize,
          minChildSize: widget.minSheetSize,
          expand: false,
          snap: true,
          //snapSizes: widget.snapPoints,
          controller: _internalController,
          builder: (context, scrollController) {
            return AbsorbPointer(
              absorbing: !widget.isInteractionEnabled,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xff161a50),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff161a50),
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
                child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.isProveedorAgregado)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    widget.isProveedorAgregado
                                        ? 'Proveedores que seleccionaste:'
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (widget.isProveedorAgregado)
                                const SizedBox(height: 8),
                              if (widget.isProveedorAgregado &&
                                  widget.proveedoresSeleccionados.isNotEmpty)
                                SizedBox(
                                  height: 70,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        widget.proveedoresSeleccionados.length,
                                    itemBuilder: (context, index) {
                                      final proveedor =
                                          widget
                                              .proveedoresSeleccionados[index];
                                      return ProveedorModelCard(
                                        proveedor: proveedor,
                                        onTap:
                                            () => widget.onProveedorTapped
                                                ?.call(proveedor),
                                        onRemove:
                                            () => widget.onProveedorRemovido
                                                ?.call(proveedor),
                                      );
                                    },
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(38, 48, 137, 1),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                        (0.1 * 255).toInt(),
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border:
                                      (_descripcionError &&
                                              !widget.isSolicitudGuardada)
                                          ? Border.all(
                                            color: Colors.red,
                                            width: 1.5,
                                          )
                                          : null,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                            ),
                                            child: SvgCache.getIconSvg(
                                              'assets/icons/ic_message_form.svg',
                                              color: const Color.fromRGBO(
                                                194,
                                                215,
                                                255,
                                                0.6,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextField(
                                                  controller:
                                                      _descripcionController,
                                                  focusNode: focusNodePrimero,
                                                  maxLines: null,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        widget.isSolicitudGuardada
                                                            ? "Se ha guardado tu solicitud, toca aqui para editarla"
                                                            : "Detalla el servicio que necesitas...",
                                                    hintStyle: const TextStyle(
                                                      color: Color.fromRGBO(
                                                        194,
                                                        215,
                                                        255,
                                                        0.6,
                                                      ),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    border: InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                  ),
                                                  showCursor: false,
                                                  onTap: () {
                                                    focusNodePrimero.unfocus();
                                                    bool?
                                                    isSheetVisibleSolicitarServicio =
                                                        true;
                                                    widget.onAbrirDetallesPressed(
                                                      isSheetVisibleSolicitarServicio,
                                                    );
                                                  },
                                                  onChanged: (_) {
                                                    if (_descripcionController
                                                        .text
                                                        .trim()
                                                        .isNotEmpty) {
                                                      if (_descripcionError) {
                                                        setState(() {
                                                          _descripcionError =
                                                              false;
                                                        });
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _log.info(
                                      "ENTRE AL BOTÓN DE SOLICITAR SERVICIO",
                                    );
                                    _log.info(
                                      "selectedCategoryIndex: ${widget.selectedCategoryIndex}",
                                    );
                                    _log.info(
                                      "onCategoriaError: ${widget.onCategoriaError}",
                                    );

                                    if (widget.onCategoriaError != null &&
                                        widget.selectedCategoryIndex == -1) {
                                      _log.info(
                                        "ENTRE A NO SELECCIONÓ CATEGORÍA",
                                      );
                                      widget.onCategoriaError!();
                                      return;
                                    }
                                    // if (_descripcionController.text
                                    //     .trim()
                                    //     .isEmpty) {
                                    //   _log.info(
                                    //     "Descripción ingresada: '${_descripcionController.text.trim()}'",
                                    //   );

                                    //   setState(() {
                                    //     _descripcionError = true;
                                    //   });
                                    //   return;
                                    // } else {
                                    //   setState(() {
                                    //     _descripcionError = false;
                                    //   });
                                    // }
                                    if (widget.datosSolicitudExistente !=
                                        null) {
                                      _log.info(
                                        "ENTRE A DATOS SOLICITUD EXISTENTE",
                                      );
                                      if (widget
                                          .proveedoresSeleccionados
                                          .isNotEmpty) {
                                        for (var proveedor
                                            in widget
                                                .proveedoresSeleccionados) {
                                          _log.info(
                                            "ENTRE AL FOR DE PROVEEDORES SELECCIONADOS",
                                          );
                                          proveedoresSeleccionadosId.add(
                                            proveedor.uid,
                                          );
                                        }
                                      }
                                      _log.info("ENTRE A CREAR LA SOLICITUD");
                                      await ServiceRepository.instance
                                          .createService(
                                            proveedoresSeleccionadosId,
                                            widget.datosSolicitudExistente!,
                                          );
                                      _log.info(
                                        "ENVIANDO SOLICITUD FINAL: ${widget.datosSolicitudExistente}",
                                      );
                                    } else {
                                      _log.severe(
                                        "NO SE PUDO CREAR LA SOLICITUD",
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3645f5),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Solicitar Servicio',
                                    style: TextStyle(
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
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
