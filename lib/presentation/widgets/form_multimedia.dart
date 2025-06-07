import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:serviexpress_app/presentation/pages/auth_page.dart';

class FormMultimedia extends StatefulWidget {
  final Function(String text, List<File> images, List<File> videos)? onSubmit;

  const FormMultimedia({super.key, this.onSubmit});

  @override
  State<FormMultimedia> createState() => FormularioMultimediaState();
}

class FormularioMultimediaState extends State<FormMultimedia> {
  final TextEditingController descripcionController = TextEditingController();
  final FocusNode focusNodeSegundo = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  final List<File> _videos = [];
  bool _isExpanded = false;
  bool _descripcionError = false;

  String get descripcionText => descripcionController.text;
  List<File> get images => _images;
  List<File> get videos => _videos;

  void setInitialData(
    String categoria,
    String description,
    List<File> initialImages,
    List<File> initialVideos,
  ) {
    if (mounted) {
      setState(() {
        descripcionController.text = description;
        _images.clear();
        _images.addAll(initialImages);
        _videos.clear();
        _videos.addAll(initialVideos);

        if (description.isNotEmpty ||
            initialImages.isNotEmpty ||
            initialVideos.isNotEmpty) {
          _isExpanded = true;
        } else {
          _isExpanded = false;
        }
      });
    }
  }

  Future<void> _pickMultiImageFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((xfile) => File(xfile.path)));
        _isExpanded = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
        _isExpanded = true;
      });
    }
  }

  Future<void> _pickMultiVideoFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultipleMedia();

    if (pickedFiles.isNotEmpty) {
      List<File> selectedVideos = [];
      List<String> videoExtensions = [
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
        '.webm',
        '.flv',
      ];

      for (XFile xfile in pickedFiles) {
        String extension = p.extension(xfile.path).toLowerCase();
        if (videoExtensions.contains(extension)) {
          selectedVideos.add(File(xfile.path));
        }
      }

      if (selectedVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(selectedVideos);
          _isExpanded = true;
        });
      } else if (pickedFiles.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionaron videos válidos.')),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _videos.add(File(video.path));
        _isExpanded = true;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
  }

  void clearForm() {
    setState(() {
      descripcionController.clear();
      _images.clear();
      _videos.clear();
      _isExpanded = false;
    });
  }

  bool hasContent() {
    return descripcionController.text.isNotEmpty ||
        _images.isNotEmpty ||
        _videos.isNotEmpty;
  }

  void mostrarErrorDescripcion() {
    setState(() {
      _descripcionError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 48, 137, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            _descripcionError
                ? Border.all(color: Colors.red, width: 1.5)
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 120),
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12,
              top: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: SvgCache.getIconSvg(
                    'assets/icons/ic_message_form.svg',
                    color: const Color.fromRGBO(194, 215, 255, 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: descripcionController,
                    focusNode: focusNodeSegundo,
                    autofocus: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText:
                          "Describe a más detalles el trabajo que requieras...",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(194, 215, 255, 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    cursorColor: Colors.white,
                    onTap: () {
                      if (!_isExpanded) {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    },
                    onChanged: (text) {
                      if (text.isNotEmpty && !_isExpanded) {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_descripcionError)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingresa los detalles',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ),

          if (_isExpanded && (_images.isNotEmpty || _videos.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (_descripcionError)
                    const Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ingresa los detalles',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  if (_images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                              right: 8,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (_videos.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                              right: 8,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeVideo(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _pickMultiImageFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  tooltip: "Seleccionar imágenes",
                ),
                IconButton(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  tooltip: "Tomar foto",
                ),
                IconButton(
                  onPressed: _pickMultiVideoFromGallery,
                  icon: const Icon(Icons.video_library, color: Colors.white),
                  tooltip: "Seleccionar videos",
                ),
                IconButton(
                  onPressed: _recordVideo,
                  icon: const Icon(Icons.videocam, color: Colors.white),
                  tooltip: "Grabar video",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    descripcionController.dispose();
    focusNodeSegundo.dispose();
    super.dispose();
  }
}
