import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';
import 'package:serviexpress_app/data/models/service_model.dart';
import 'package:serviexpress_app/data/repositories/service_repository.dart';
import 'package:serviexpress_app/presentation/home/home_cliente/form_multimedia.dart';

class DraggableSheetSolicitarServicioDetallado extends StatefulWidget {
  final GlobalKey globalKeyServicioDetalladoPhotos;
  final GlobalKey globalKeyServicioDetalladoVoice;
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;

  final ServiceModel? initialData;
  final Function(ServiceModel) onGuardarSolicitudCallback;

  final int selectedCategoryIndex;
  //final Function(bool) isSolicitudEnviada;

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
    required this.selectedCategoryIndex,
    //required this.isSolicitudEnviada,
    required this.globalKeyServicioDetalladoPhotos,
    required this.globalKeyServicioDetalladoVoice,
  });
  @override
  State<DraggableSheetSolicitarServicioDetallado> createState() =>
      DraggableSheetState();
}

class DraggableSheetState
    extends State<DraggableSheetSolicitarServicioDetallado> {
  final Logger _log = Logger('DraggableSheetState');
  late DraggableScrollableController _internalController;
  bool _isDismissing = false;
  final GlobalKey<FormularioMultimediaState> _formMultimediaKey =
      GlobalKey<FormularioMultimediaState>();

  late ValueNotifier<int> _selectedCategoryIndex;

  double _lastKnownSheetSize = 0.0;
  bool _isReadyForInteraction = false;

  @override
  void initState() {
    super.initState();
    _internalController = DraggableScrollableController();

    _lastKnownSheetSize = widget.targetInitialSize;

    _internalController.addListener(_onChanged);
    _selectedCategoryIndex = ValueNotifier<int>(widget.selectedCategoryIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _internalController.animateTo(
        widget.targetInitialSize,
        duration: widget.entryAnimationDuration,
        curve: widget.entryAnimationCurve,
      );

      if (mounted) {
        _isReadyForInteraction = true;
      }

      if (widget.initialData != null &&
          _formMultimediaKey.currentState != null) {
        _formMultimediaKey.currentState?.setInitialData(
          widget.initialData?.categoria ?? '',
          widget.initialData!.descripcion,
          widget.initialData!.fotosFiles ?? [],
          widget.initialData!.videosFiles ?? [],
          widget.initialData!.audioFiles ?? [],
        );
      }
    });
  }

  void animateToDismiss() async {}

  @override
  void dispose() {
    _internalController.removeListener(_onChanged);
    _internalController.dispose();
    _selectedCategoryIndex.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_isReadyForInteraction || !_internalController.isAttached) return;

    final currentSize = _internalController.size;
    final double keyboardDismissThreshold = widget.targetInitialSize * 1;

    if (currentSize < _lastKnownSheetSize &&
        currentSize < keyboardDismissThreshold) {
      FocusScope.of(context).unfocus();
    }
    _lastKnownSheetSize = currentSize;

    if (!_isDismissing && currentSize <= widget.minSheetSize + 0.01) {
      _isDismissing = true;
      widget.onDismiss?.call();
    } else if (currentSize > widget.minSheetSize + 0.01) {
      _isDismissing = false;
    }
  }

  @override
  void didUpdateWidget(DraggableSheetSolicitarServicioDetallado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryIndex != widget.selectedCategoryIndex) {
      _selectedCategoryIndex.value = widget.selectedCategoryIndex;
    }
  }

  Future<void> _accionAgregarSolicitud() async {
    if (_formMultimediaKey.currentState == null) {
      return;
    }

    if (_formMultimediaKey.currentState!.descripcionText.trim().isEmpty) {
      _formMultimediaKey.currentState!.mostrarErrorDescripcion();
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
    final List<File> audio = _formMultimediaKey.currentState!.audios;

    String id = ServiceRepository.instance.generateServiceId();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _log.info('Usuario no autenticado');
    }

    final ServiceModel service = ServiceModel(
      id: id,
      categoria: categoriaSeleccionada,
      descripcion: descripcion,
      estado: 'Pendiente',
      clientId: currentUser?.uid ?? '',
      workerId: '',
      fotosFiles: fotos,
      videosFiles: videos,
      audioFiles: audio,
    );

   //widget.isSolicitudEnviada(true);
    widget.onGuardarSolicitudCallback(service);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_internalController.size > widget.minSheetSize + 0.01) {
            await _internalController.animateTo(
              widget.minSheetSize,
              duration: widget.entryAnimationDuration,
              curve: Curves.easeInOut,
            );
            widget.onDismiss?.call();
          } else {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: LayoutBuilder(
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
                child: Stack(
                  children: [
                    CustomScrollView(
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
                                const SizedBox(height: 10),
                                const Text(
                                  'Cuéntanos Más',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),

                                FormMultimedia(
                                  key: _formMultimediaKey,
                                  keyServicioDetalladoPhotos:
                                      widget.globalKeyServicioDetalladoPhotos,
                                  keyServicioDetalladoVoice:
                                      widget.globalKeyServicioDetalladoVoice,
                                ),
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
                    Positioned(
                      top: 10,
                      right: 15,
                      child: GestureDetector(
                        onTap: () async {
                          await _internalController.animateTo(
                            widget.minSheetSize,
                            duration: widget.entryAnimationDuration,
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 27,
                          height: 27,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3645f5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
