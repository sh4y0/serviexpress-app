import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/solicitud_servicio_model.dart';
import 'package:serviexpress_app/presentation/widgets/form_multimedia.dart';

class DraggableSheetSolicitarServicioDetallado extends StatefulWidget {
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;

  final SolicitudServicioModel? initialData;
  final Function(SolicitudServicioModel) onGuardarSolicitudCallback;

  const DraggableSheetSolicitarServicioDetallado({
    super.key,
    this.onDismiss,
    required this.targetInitialSize,
    this.minSheetSize = 0.0,
    this.maxSheetSize = 0.95,
    required this.snapPoints,
    this.entryAnimationDuration = const Duration(milliseconds: 300),
    this.entryAnimationCurve = Curves.easeOutCubic,
    this.initialData,
    required this.onGuardarSolicitudCallback,
  });
  @override
  State<DraggableSheetSolicitarServicioDetallado> createState() =>
      DraggableSheetState();
}

class DraggableSheetState
    extends State<DraggableSheetSolicitarServicioDetallado> {
  late DraggableScrollableController _internalController;
  bool _isDismissing = false;
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(-1);
  final GlobalKey<FormularioMultimediaState> _formMultimediaKey =
      GlobalKey<FormularioMultimediaState>();

  @override
  void initState() {
    super.initState();
    _internalController = DraggableScrollableController();
    _internalController.addListener(_onChanged);

    if (widget.initialData != null) {
      if (widget.initialData!.categoria != null) {
        final categories = CategoryMock.getCategories();
        int initialIndex = categories.indexWhere(
          (cat) => cat.name == widget.initialData!.categoria,
        );
        if (initialIndex != -1) {
          _selectedCategoryIndex.value = initialIndex;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _internalController.isAttached) {
        _internalController.animateTo(
          widget.targetInitialSize,
          duration: widget.entryAnimationDuration,
          curve: widget.entryAnimationCurve,
        );
      }
      if (widget.initialData != null &&
          _formMultimediaKey.currentState != null) {
        _formMultimediaKey.currentState?.setInitialData(
          widget.initialData!.categoria ?? "",
          widget.initialData!.descripcion ?? "",
          widget.initialData!.fotos.toList(),
          widget.initialData!.videos.toList(),
        );
      }
    });
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

  void _accionAgregarSolicitud() {
    if (_formMultimediaKey.currentState == null) {
      return;
    }

    String? categoriaSeleccionada;
    if (_selectedCategoryIndex.value != -1 &&
        _selectedCategoryIndex.value < CategoryMock.getCategories().length) {
      categoriaSeleccionada =
          CategoryMock.getCategories()[_selectedCategoryIndex.value].name;
    }

    final String descripcion = _formMultimediaKey.currentState!.descripcionText;
    final List<File> fotos = _formMultimediaKey.currentState!.images;
    final List<File> videos = _formMultimediaKey.currentState!.videos;

    final data = SolicitudServicioModel(
      categoria: categoriaSeleccionada,
      descripcion: descripcion,
      fotos: fotos.toList(),
      videos: videos.toList(),
    );

    widget.onGuardarSolicitudCallback(data);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (builder, constraints) {
        return DraggableScrollableSheet(
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
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.15,
                            child: Container(
                              margin: const EdgeInsets.all(13),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                color: Color.fromRGBO(117, 148, 255, 1),
                                shape: BoxShape.rectangle,
                              ),
                              width: 154,
                              height: 2,
                            ),
                          ),

                          const Text(
                            'Brinda mas detalle al Proveedor',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              
                            ),
                          ),

                          FormMultimedia(key: _formMultimediaKey),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _accionAgregarSolicitud,
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
                                'Guardar Solicitud',
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}
