import 'package:flutter/material.dart';

class Alerts {
  Alerts._privateConstructor();
  static final Alerts instance = Alerts._privateConstructor();

  Future<void> showSuccessAlert(
    BuildContext context,
    String message, {
    VoidCallback? onOk,
  }) async {
    return _showAnimatedDialog(
      context,
      message: message,
      isError: false,
      onOk: onOk,
    );
  }

  Future<void> showErrorAlert(BuildContext context, String message) async {
    return _showAnimatedDialog(context, message: message, isError: true);
  }

  Future<void> showInfoAlert(BuildContext context, String message) async {
    return _showAnimatedDialog(context, message: message, isError: true);
  }

  Future<bool> showConfirmAlert(
    BuildContext context,
    String message, {
    String confirmText = "Sí",
    String cancelText = "Cancelar",
  }) async {
    bool result = false;

    await _showAnimatedDialog(
      context,
      message: message,
      isError: false,
      isConfirmation: true,
      confirmText: confirmText,
      cancelText: cancelText,
      onOk: () => result = true,
      onCancel: () => result = false,
    );

    return result;
  }

  Future<void> _showAnimatedDialog(
    BuildContext context, {
    required String message,
    required bool isError,
    VoidCallback? onOk,
    bool isConfirmation = false,
    VoidCallback? onCancel,
    String confirmText = "Sí",
    String cancelText = "Cancelar",
  }) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Alerta",
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              backgroundColor: const Color(0xFF101328),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 20,
              shadowColor: Colors.black54,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConfirmation
                        ? Icons.help_outline
                        : isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color:
                        isConfirmation
                            ? Colors.amberAccent
                            : isError
                            ? Colors.redAccent
                            : const Color(0xFF4A66FF),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isConfirmation)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(cancelText),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            if (onCancel != null) onCancel();
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF4A66FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(confirmText),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            if (onOk != null) onOk();
                          },
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF4A66FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.black45,
                          elevation: 5,
                        ),
                        child: Text(isError ? "Cerrar" : "OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (!isError && onOk != null) {
                            onOk();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
