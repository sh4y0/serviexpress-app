import 'package:flutter/material.dart';

class Alerts {
  Alerts._privateConstructor();
  static final Alerts instance = Alerts._privateConstructor();

  void showSuccessAlert(BuildContext context, String message) {
    _showAnimatedDialog(
      context,
      title: "Éxito",
      message: message,
      isError: false,
    );
  }

  void showErrorAlert(BuildContext context, String message) {
    _showAnimatedDialog(
      context,
      title: "Error",
      message: message,
      isError: true,
    );
  }

  void _showAnimatedDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isError,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Alerta",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              backgroundColor: const Color(0xFF101328),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(color: Colors.white70),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4A66FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isError ? "Cerrar" : "OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
