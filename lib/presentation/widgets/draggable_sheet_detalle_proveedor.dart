import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class DraggableSheetDetalleProveedor extends StatefulWidget {
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;

  const DraggableSheetDetalleProveedor({
    super.key,
    this.onDismiss,
    required this.targetInitialSize,
    this.minSheetSize = 0.0,
    this.maxSheetSize = 0.95,
    required this.snapPoints,
    this.entryAnimationDuration = const Duration(milliseconds: 200),
    this.entryAnimationCurve = Curves.easeOutCubic,
  });
  @override
  State<DraggableSheetDetalleProveedor> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheetDetalleProveedor> {
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

  @override
  Widget build(BuildContext context) {
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 29.5),
                            decoration: const BoxDecoration(                      
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(117, 148, 255, 1),
                              shape: BoxShape.rectangle,
                            ),
                            width: 154,
                            height: 4,
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
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rodri Gutierrez',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '4.9 (120+ review)',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Desarrollador Flutter',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Los sistemas de aire acondicionado pueden experimentar diversos problemas y su solucion depende del problema especifico que este enfrentando',
                            style: TextStyle(
                              color: AppColor.textInput,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Reseñas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                '(120+ review)',
                                style: TextStyle(
                                  color: Color(0xff3d4d8a),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0c0d23),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/new_user.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Allan Sagastegui',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Usuario Nuevo',
                                            style: TextStyle(
                                              color: AppColor.textInput,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '5.0',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                const Text(
                                  'Se solicito un servicio acelerado y la entrega del proveedor fue muy rapida y antes de lo esperado.',
                                  style: TextStyle(
                                    color: AppColor.textInput,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.chat);
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
                                'Cotizar servicio',
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
