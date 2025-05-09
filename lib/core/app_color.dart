import 'package:flutter/material.dart';

class AppColor {
  //backgroud
  static const LinearGradient backgroudGradient = LinearGradient(
    colors: [
      Color(0xFF090B19),
      Color(0xFF141830),
      Color(0xFF171A33),
      Color(0xFF15182D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  //Nav Button Login
  static const Color loginDeselect = Color(0xFF161A50);
  static const Color loginSelect = Color(0xFF252FAE);

  //Color Text Welcome
  static const Color textWelcome = Color(0xFF828F9C);

  //Color input
  static const Color colorInput = Color(0xFF4A66FF);
  static const Color textInput = Color(0xFF8689A5);

  //Color botones principales
  static const Color btnColor = Color(0xFF4A66FF);

  //Color de fondo de verificacion
  static const Color bgVerification = Color(0xFF101328);
  static const Color bgCard = Color(0xFF161A50);
  static const Color bgCircle = Color(0xFF2AB749);
}