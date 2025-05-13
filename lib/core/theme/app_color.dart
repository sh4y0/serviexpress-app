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

  //Color Nav Button Login
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

  //Color barra de navegacion del chat
  static const Color bgChat = Color(0xFF101328);
  static const Color bgBack = Color(0xFF3D4976);

  //Color fondo de mensajes
  static const Color bgMsgUser = Color(0xFF263089);
  static const Color bgMsgClient = Color(0xFF161A50);

  //Color propuesta
  static const Color bgProp = Color(0xFF00074A);

  //Color fondo para escribir mensaje
  static const Color bgContendeor = Color(0xFF101328);
  static const Color bgShadow = Color(0xFF262B56);
  static const Color bgLabel = Color(0xFF141830);
  static const Color txtMsg = Color(0xFF686C8F);
}