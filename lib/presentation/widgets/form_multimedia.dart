import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:serviexpress_app/presentation/pages/auth_page.dart';

class FormMultimedia extends StatefulWidget {
  final Function(String text, List<File> images, List<File> videos)? onSubmit;

  const FormMultimedia({super.key, this.onSubmit});

  @override
  State<FormMultimedia> createState() => FormularioMultimediaState();
}

class FormularioMultimediaState extends State<FormMultimedia> {
  final TextEditingController descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  final List<File> _videos = [];
  bool _isExpanded = false;

  String get descripcionText => descripcionController.text;
  List<File> get images => _images;
  List<File> get videos => _videos;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
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

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videos.add(File(video.path));
        _isExpanded = true;
      });
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

  // void _submitContent() {
  //   if (widget.onSubmit != null) {
  //     widget.onSubmit!(descripcionController.text, _images, _videos);
  //   }

  //   // setState(() {
  //   //   descripcionController.clear();
  //   //   _images.clear();
  //   //   _videos.clear();
  //   //   _isExpanded = false;
  //   // });
  // }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Padding(
                 padding: const EdgeInsets.only(top: 9),
                 child: SvgCache.getIconSvg('assets/icons/ic_message_form.svg', color: const Color.fromRGBO(194, 215, 255, 0.6)),
               ),
                Expanded(
                  child: TextField(
                    controller: descripcionController,
                    maxLines: null,
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
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height:
                _isExpanded && (_images.isNotEmpty || _videos.isNotEmpty)
                    ? null
                    : 0,
            child:
                _isExpanded && (_images.isNotEmpty || _videos.isNotEmpty)
                    ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (_images.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            _images[index],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                            Container(
                              height: 80,
                              margin: const EdgeInsets.only(top: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _videos.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => _removeVideo(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                    )
                    : const SizedBox.shrink(),
          ),

          Container(
            //padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    tooltip: "Seleccionar imagen",
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    tooltip: "Tomar foto",
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library, color: Colors.white),
                    tooltip: "Seleccionar video",
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _recordVideo,
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    tooltip: "Grabar video",
                  ),
                ),

                //const Spacer(),

                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: TextButton.icon(
                //     onPressed: _submitContent,
                //     icon: const Icon(Icons.send, color: Colors.white, size: 16),
                //     label: const Text(
                //       "Tomar o Subir",
                //       style: TextStyle(color: Colors.white, fontSize: 14),
                //     ),
                //     style: TextButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //     ),
                //   ),
                // ),
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
    super.dispose();
  }
}
