import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColor.btnColor,
        secondary: AppColor.colorInput,
        surface: AppColor.bgVerification,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColor.textWelcome),
        bodyMedium: TextStyle(color: AppColor.textInput),
        titleLarge: TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.textInput, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.colorInput, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        hintStyle: const TextStyle(color: AppColor.textInput),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.btnColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColor.textWelcome, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension(
          backgroundGradient: AppColor.backgroudGradient,
          loginSelect: AppColor.loginSelect,
          loginDeselect: AppColor.loginDeselect,
          bgVerification: AppColor.bgVerification,
          bgCard: AppColor.bgCard,
          bgMsgUser: AppColor.bgMsgUser,
          bgMsgClient: AppColor.bgMsgClient,
          bgProp: AppColor.bgProp,
          txtMsg: AppColor.txtMsg,
        ),
      ],
    );
  }
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final LinearGradient backgroundGradient;
  final Color loginSelect;
  final Color loginDeselect;
  final Color bgVerification;
  final Color bgCard;
  final Color bgMsgUser;
  final Color bgMsgClient;
  final Color bgProp;
  final Color txtMsg;

  const AppColorsExtension({
    required this.backgroundGradient,
    required this.loginSelect,
    required this.loginDeselect,
    required this.bgVerification,
    required this.bgCard,
    required this.bgMsgUser,
    required this.bgMsgClient,
    required this.bgProp,
    required this.txtMsg,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith() => this;

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) => this;
}

// Cómo usar los colores en cualquier widget:
// final customColors = Theme.of(context).extension<AppColorsExtension>()!;
// customColors.backgroundGradient