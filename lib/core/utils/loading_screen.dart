import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoadingScreen {
  static final LoadingScreen _instance = LoadingScreen._internal();
  factory LoadingScreen() => _instance;
  LoadingScreen._internal();

  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _overlayEntry = OverlayEntry(
      builder: (context) => const _ImpulseRotationOverlay(),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ImpulseRotationOverlay extends StatefulWidget {
  const _ImpulseRotationOverlay();

  @override
  State<_ImpulseRotationOverlay> createState() =>
      _ImpulseRotationOverlayState();
}

class _ImpulseRotationOverlayState extends State<_ImpulseRotationOverlay> {
  final ValueNotifier<double> _angle = ValueNotifier(0);
  Timer? _timer;

  double _baseAngle = 0;
  int _frame = 0;

  static const int _totalFrames = 60;
  static const Duration frameDuration = Duration(milliseconds: 16);
  static const Duration pauseDuration = Duration(milliseconds: 300);

  static const double _retroceso = -0.2;
  static const double _avance = 2 * math.pi + 0.1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startImpulseLoop();
  }

  void _startImpulseLoop() {
    _frame = 0;
    _timer?.cancel();

    _timer = Timer.periodic(frameDuration, (timer) {
      final t = _frame / _totalFrames;
      double curvedT = Curves.easeInOutBack.transform(t);

      final currentRotation = _retroceso + curvedT * (_avance - _retroceso);

      _angle.value = _baseAngle + currentRotation;

      _frame++;

      if (_frame >= _totalFrames) {
        timer.cancel();
        _baseAngle += 2 * math.pi;
        _angle.value = _baseAngle;

        Future.delayed(pauseDuration, () {
          if (mounted) _startImpulseLoop();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _angle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Color.fromRGBO(0, 0, 0, 0.85),
        ),
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: _angle,
            builder: (_, angle, child) {
              return Transform.rotate(angle: angle, child: child);
            },
            child: Image.asset(
              'assets/icons/logo_serviexpress-nobg.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
