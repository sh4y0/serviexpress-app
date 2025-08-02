class ProfileScreenStrings {
  static const String deactivateAccount = "Desactivar cuenta";
  static const String logout = "Cerrar sesión";

  static const String takePhoto = "Tomar Foto";
  static const String uploadPhoto = "Subir Foto";
  static const String cancel = "Cancelar";
  static const String ok = "OK";

  static const String iconPath = "iconPath";
  static const String title = "title";
  static const String icon = "icon";
  static const String trailing = "trailing";

  static final List<Map<String, dynamic>> options = [
    {
      "iconPath": "assets/icons/ic_privacidad.svg",
      "title": "Privacidad",
      "trailing": "",
    },
    {
      "iconPath": "assets/icons/ic_notify.svg",
      "title": "Notificaciones",
      "trailing": "ON",
    },
    {
      "iconPath": "assets/icons/ic_idioma.svg",
      "title": "Idioma",
      "trailing": "English",
    },
  ];

  static final List<Map<String, dynamic>> secondaryOptions = [
    {
      "iconPath": "assets/icons/ic_verification_mov.svg",
      "title": "Verificacion móvil",
    },
    {
      "iconPath": "assets/icons/ic_historial.svg",
      "title": "Historial de actividad",
    },
  ];
}
