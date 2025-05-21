import 'package:flutter/material.dart';

class LoadingScreen {
  static final LoadingScreen _instance = LoadingScreen._internal();
  factory LoadingScreen() => _instance;
  LoadingScreen._internal();

  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => const Stack(
            children: [
              ModalBarrier(
                dismissible: false,
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      backgroundColor: Color(0xFF4A66FF),
                      color: Color(0xFF101328),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
