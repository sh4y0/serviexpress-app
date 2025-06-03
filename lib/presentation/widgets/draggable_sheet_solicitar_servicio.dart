import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/proveedor_model.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
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
  final Function(String? categoriaSeleccionada) onAbrirDetallesPressed;

  final List<ProveedorModel> proveedoresSeleccionados;
  final Function(ProveedorModel)? onProveedorRemovido;
  final Function(ProveedorModel)? onProveedorTapped;

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
  });
  @override
  ConsumerState<DraggableSheetSolicitarServicio> createState() =>
      DraggableSheetSolicitarServicioState();
}

class DraggableSheetSolicitarServicioState
    extends ConsumerState<DraggableSheetSolicitarServicio> {
  final sheetKeyInDraggable = GlobalKey();
  late DraggableScrollableController _internalController;
  bool _isDismissing = false;
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(-1);
  late TextEditingController _descripcionController = TextEditingController();
  final FocusNode focusNodePrimero = FocusNode();

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

  void resetSheet() {
    if (mounted) {
      setState(() {
        _selectedCategoryIndex.value = -1;
      });
    }
  }

  @override
  void dispose() {
    _internalController.removeListener(_onChanged);
    _internalController.dispose();
    _selectedCategoryIndex.dispose();
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
    // bool hayDatosParaEditar =
    //     widget.datosSolicitudExistente != null &&
    //     widget.datosSolicitudExistente!.hasData;
    final categories = CategoryMock.getCategories();

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
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                                child: Text(
                                  'Proveedores que seleccionaste:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (widget.proveedoresSeleccionados.isNotEmpty)
                                SizedBox(
                                  height: 80,
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
                                  top: 12,
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
                                            child: TextField(
                                              controller:
                                                  _descripcionController,
                                              focusNode: focusNodePrimero,
                                              maxLines: null,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Detalla el servicio que necesitas...",
                                                hintStyle: TextStyle(
                                                  color: Color.fromRGBO(
                                                    194,
                                                    215,
                                                    255,
                                                    0.6,
                                                  ),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                              showCursor: false,
                                              onTap: () {
                                                focusNodePrimero.unfocus();
                                                String? catSeleccionada;
                                                if (_selectedCategoryIndex
                                                        .value !=
                                                    -1) {
                                                  catSeleccionada =
                                                      categories[_selectedCategoryIndex
                                                              .value]
                                                          .name;
                                                }
                                                print(
                                                  "Categoria seleccionada onAbrirDetalles: ${_selectedCategoryIndex.value}",
                                                );
                                                print(
                                                  "Categoria seleccionada onAbrirDetalles: $catSeleccionada",
                                                );
                                                widget.onAbrirDetallesPressed(
                                                  catSeleccionada,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (widget.datosSolicitudExistente !=
                                        null) {
                                      widget.datosSolicitudExistente!.workerId =
                                          "dn9aBHCyJjbqJNZ0Lv1r0eKfMTX2";
                                      await ServiceRepository.instance
                                          .createService(
                                            widget.datosSolicitudExistente!,
                                          );
                                      print(
                                        "ENVIANDO SOLICITUD FINAL: ${widget.datosSolicitudExistente}",
                                      );
                                    } else {
                                      print("NO SE PUDO CREAR LA SOLICITUD");
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
