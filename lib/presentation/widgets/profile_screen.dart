// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/data/repositories/auth_repository.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';
import 'package:serviexpress_app/presentation/viewmodels/desactive_account_view_model.dart';
import 'package:serviexpress_app/presentation/widgets/map_style_loader.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isProvider;
  const ProfileScreen({super.key, required this.isProvider});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? user;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColor.bgMsgClient,
            title: const Text("Cerrar Sesion"),
            content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  AuthRepository.instance.logout();
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil("/login", (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sesión cerrada")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text(
                  "Cerrar Sesion",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _getUserById() async {
    final uid = await UserPreferences.getUserId();
    if (uid == null) return;
    var userFetch = await UserRepository.instance.getCurrentUser(uid);
    if (!mounted) return;
    setState(() {
      user = userFetch;
    });
  }

  void _listenToViewModel() {
    ref.listen<ResultState>(desactivateAccountViewModelProvider, (
      _,
      next,
    ) async {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success(data: final data):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showSuccessAlert(
              context,
              data,
              onOk: () {
                Navigator.pushReplacementNamed(context, AppRoutes.startPage);
              },
            );
          }

          break;
        case Failure(error: final error):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showErrorAlert(context, error.message);
          }
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserById();
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColor.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text("Tomar Foto"),
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text("Subir Foto"),
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text("Cancelar"),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
        Navigator.of(context).pop();
        _showConfirmDialog();
      }
    } catch (e) {
      Alerts.instance.showErrorAlert(
        context,
        "No se pudo seleccionar la imagen.",
      );
    }
  }

  void _showConfirmDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColor.bgCard,
            title: const Center(
              child: Text(
                "Confirmar imagen de perfil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: CircleAvatar(
              radius: 90,
              backgroundImage: FileImage(File(_selectedImage!.path)),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.btnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _uploadAndRefreshUser(),
                child: const Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
    );
  }

  Future<void> _uploadAndRefreshUser() async {
    if (_selectedImage == null) return;

    try {
      LoadingScreen.show(context);

      final uid = await UserPreferences.getUserId();
      if (uid == null) throw Exception("Usuario no autenticado");

      await UserRepository.instance.addUserProfilePhoto(
        File(_selectedImage!.path),
        uid,
      );

      _getUserById();

      setState(() {
        _selectedImage = null;
      });

      Navigator.of(context).pop();
      Alerts.instance.showSuccessAlert(
        context,
        "Imagen actualizada exitosamente",
      );
    } catch (e) {
      Alerts.instance.showErrorAlert(
        context,
        "Error al subir la imagen: ${e.toString()}",
      );
    } finally {
      LoadingScreen.hide();
    }
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child:
                    _selectedImage != null
                        ? Image.file(File(_selectedImage!.path))
                        : (user!.imagenUrl != null &&
                                user!.imagenUrl!.isNotEmpty
                            ? Image.network(user!.imagenUrl!)
                            : Image.asset("assets/images/avatar.png")),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToViewModel();
    final options = [
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

    final options2 = [
      {
        "iconPath": "assets/icons/ic_verification_mov.svg",
        "title": "Verificacion móvil",
      },
      {
        "iconPath": "assets/icons/ic_historial.svg",
        "title": "Historial de actividad",
        //"route": AppRoutes.cambioRol,
      },
      widget.isProvider
          ? {
            "icon": Icons.published_with_changes,
            "title": "Cambiar a Cliente",
            "route": AppRoutes.home,
          }
          : {
            "icon": Icons.published_with_changes,
            "title": "Cambiar a Trabajador",
            "route": AppRoutes.homeProvider,
          },
    ];
    return Scaffold(
      backgroundColor: AppColor.bgVerification,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showFullImage(context);
                                },
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 140,
                                      height: 140,
                                      child:
                                          _selectedImage != null
                                              ? Image.file(
                                                File(_selectedImage!.path),
                                                fit: BoxFit.cover,
                                              )
                                              : (user!.imagenUrl != null &&
                                                      user!
                                                          .imagenUrl!
                                                          .isNotEmpty
                                                  ? FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/images/avatar.png",
                                                    image: user!.imagenUrl!,
                                                    fit: BoxFit.cover,
                                                    imageErrorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        "assets/images/avatar.png",
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                  : Image.asset(
                                                    "assets/images/avatar.png",
                                                    fit: BoxFit.cover,
                                                  )),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                child: GestureDetector(
                                  onTap: _showImageSourceOptions,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_edit.svg",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user!.nombreCompleto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user!.email,
                              style: const TextStyle(
                                color: AppColor.txtEmailPhone,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "|",
                              style: TextStyle(
                                color: AppColor.txtEmailPhone,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              user!.telefono,
                              style: const TextStyle(
                                color: AppColor.txtEmailPhone,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < options.length) {
                            final option = options[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.grey.withAlpha(
                                  (0.3 * 255).toInt(),
                                ),
                                highlightColor: Colors.grey.withAlpha(
                                  (0.18 * 255).toInt(),
                                ),
                                onTap: () async {
                                  final route = option["route"];
                                  if (route != null) {
                                    if (route == AppRoutes.home) {
                                      final mapStyle =
                                          await MapStyleLoader.loadStyle();
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        route,
                                        (route) => false,
                                        arguments: mapStyle,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        route,
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                child: ListTile(
                                  leading: SvgPicture.asset(
                                    option["iconPath"] as String,
                                    width: 24,
                                    height: 24,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  title: Text(
                                    option["title"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    option["trailing"] as String,
                                    style: const TextStyle(
                                      color: AppColor.txtTrailing,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        separatorBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        itemCount: options.length,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < options2.length) {
                            final option = options2[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.grey.withAlpha(
                                  (0.3 * 255).toInt(),
                                ),
                                highlightColor: Colors.grey.withAlpha(
                                  (0.18 * 255).toInt(),
                                ),
                                onTap: () async {
                                  if (option["route"] != null) {
                                    if (option["route"] == AppRoutes.home) {
                                      final mapStyle =
                                          await MapStyleLoader.loadStyle();
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        option["route"] as String,
                                        (route) => false,
                                        arguments: mapStyle,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        option["route"] as String,
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                child: ListTile(
                                  leading:
                                      option["iconPath"] != null
                                          ? SvgPicture.asset(
                                            option["iconPath"] as String,
                                            width: 24,
                                            height: 24,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                          : Icon(
                                            option["icon"] as IconData,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  title: Text(
                                    option["title"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        separatorBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        itemCount: options2.length,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: AppColor.bgItmProfile,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              highlightColor: Colors.grey.withAlpha(
                                (0.18 * 255).toInt(),
                              ),
                              onTap: () async {
                                final confirmed = await Alerts.instance
                                    .showConfirmAlert(
                                      context,
                                      "¿Estás seguro de que deseas desactivar tu cuenta?",
                                      confirmText: "Sí, continuar",
                                      cancelText: "Cancelar",
                                    );

                                if (confirmed) {
                                  await ref
                                      .read(
                                        desactivateAccountViewModelProvider
                                            .notifier,
                                      )
                                      .deactivateCurrentUserAccount();
                                }
                              },
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  "assets/icons/ic_delete_account.svg",
                                ),
                                title: const Text(
                                  "Inhabilitar cuenta",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                              highlightColor: Colors.grey.withAlpha(
                                (0.18 * 255).toInt(),
                              ),
                              onTap: () => _logout(context),
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  "assets/icons/ic_exit.svg",
                                ),
                                title: const Text(
                                  "Cerrar sesión",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
