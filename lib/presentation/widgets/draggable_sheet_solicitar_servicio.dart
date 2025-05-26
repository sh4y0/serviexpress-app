import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/data/models/category_model.dart';
import 'package:serviexpress_app/data/models/data_mock.dart';
import 'package:serviexpress_app/presentation/widgets/category_button.dart';
import 'package:serviexpress_app/presentation/widgets/form_multimedia.dart';

class DraggableSheetSolicitarServicio extends StatefulWidget {
  final VoidCallback? onDismiss;
  final double targetInitialSize;
  final double minSheetSize;
  final double maxSheetSize;
  final List<double> snapPoints;
  final Duration entryAnimationDuration;
  final Curve entryAnimationCurve;

  const DraggableSheetSolicitarServicio({
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
  State<DraggableSheetSolicitarServicio> createState() =>
      _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheetSolicitarServicio> {
  final sheetKeyInDraggable = GlobalKey();
  late DraggableScrollableController _internalController;
  bool _isDismissing = false;
  final ValueNotifier<int> _selectedCategoryIndex = ValueNotifier<int>(0);

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
                      padding: const EdgeInsets.symmetric(
                        //vertical: 20.5,
                        horizontal: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.15,
                            child: Container(
                              margin: const EdgeInsets.all(13),
                              decoration: const BoxDecoration(                      
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                color: Color.fromRGBO(117, 148, 255, 1),
                                shape: BoxShape.rectangle,
                              ),
                              width: 154,
                              height: 2,
                              ),
                          ),
                          SizedBox(
                            height: 56,
                            // margin: const EdgeInsets.symmetric(
                            //   //horizontal: 6,
                            //   //vertical: 39,
                            // ),
                            child: ValueListenableBuilder<int>(
                              valueListenable: _selectedCategoryIndex,
                              builder: (context, selectedIndex, _) {
                                return ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var category =
                                        CategoryModel.getCategories()[index];

                                    return CategoryButton(
                                      category: category,
                                      index: index,
                                      selectedCategoryIndexNotifier:
                                          _selectedCategoryIndex,
                                    );
                                  },
                                  itemCount: DataMock.mockData.length,
                                );
                              },
                            ),
                          ),

                          //const SizedBox(height: 24),
                          const FormMultimedia(),
                          const SizedBox(height: 12),

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
                                'Obtener cotizaciones',
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
