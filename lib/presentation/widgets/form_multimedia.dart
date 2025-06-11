import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';

class FormMultimedia extends StatefulWidget {
  final Function(
    String text,
    List<File> images,
    List<File> videos,
    List<File> audios,
  )?
  onSubmit;

  const FormMultimedia({super.key, this.onSubmit});

  @override
  State<FormMultimedia> createState() => FormularioMultimediaState();
}

class FormularioMultimediaState extends State<FormMultimedia>
    with TickerProviderStateMixin {
  final TextEditingController descripcionController = TextEditingController();
  final FocusNode focusNodeSegundo = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  final List<File> _videos = [];
  final List<File> _audios = [];
  final AudioRecorder _audioRecorder = AudioRecorder();
  final List<AudioPlayer> _audioPlayers = [];

  bool _isExpanded = false;
  bool _descripcionError = false;
  bool _isRecording = false;

  String get descripcionText => descripcionController.text;
  int _recordingSeconds = 0;

  late AnimationController _micAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _micScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  List<File> get images => _images;
  List<File> get videos => _videos;
  List<File> get audios => _audios;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _micScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void setInitialData(
    String categoria,
    String description,
    List<File> initialImages,
    List<File> initialVideos,
    List<File> initialAudios,
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
    if (pickedFiles.isNotEmpty && mounted) {
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

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(
          dir.path,
          'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
          _isExpanded = true;
        });

        _micAnimationController.forward();
        _pulseAnimationController.repeat(reverse: true);
        _waveAnimationController.repeat();

        _startRecordingTimer();
      }
    } catch (e) {
      debugPrint('Error al iniciar grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la grabación.')),
      );
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingSeconds++;
        });
        _startRecordingTimer();
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null && mounted) {
        final audioFile = File(path);
        final player = AudioPlayer();
        await player.setFilePath(path);

        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
          _audios.add(audioFile);
          _audioPlayers.add(player);
        });
      }
    } catch (e) {
      debugPrint('Error al detener grabación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      _micAnimationController.reverse();
      _pulseAnimationController.stop();
      _waveAnimationController.stop();
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

  void _removeAudio(int index) {
    setState(() {
      _audioPlayers[index].dispose();
      _audioPlayers.removeAt(index);
      _audios.removeAt(index);
      _checkIfStillExpanded();
    });
  }

  void _checkIfStillExpanded() {
    if (descripcionController.text.isEmpty &&
        _images.isEmpty &&
        _videos.isEmpty &&
        _audios.isEmpty) {
      _isExpanded = false;
    }
  }

  void clearForm() {
    setState(() {
      descripcionController.clear();
      _images.clear();
      _videos.clear();
      for (var player in _audioPlayers) {
        player.dispose();
      }
      _audioPlayers.clear();
      _audios.clear();
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

  String _formatRecordingTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildRecordingIndicator() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Grabando... ${_formatRecordingTime(_recordingSeconds)}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 3,
                height:
                    12 +
                    (math.sin(_waveAnimation.value * math.pi * 2 + index) * 8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.7 * 255).toInt()),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ],
        );
      },
    );
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
              bottom: 2,
              top: 8,
            ),
            child:
                _isRecording
                    ? _buildRecordingIndicator()
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: SvgCache.getIconSvg(
                            'assets/icons/ic_message_form.svg',
                            color:
                                _descripcionError
                                    ? Colors.red
                                    : const Color.fromRGBO(194, 215, 255, 0.6),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Describe a más detalles el trabajo que requieras...",
                              hintStyle: TextStyle(
                                color:
                                    _descripcionError
                                        ? Colors.red
                                        : const Color.fromRGBO(
                                          194,
                                          215,
                                          255,
                                          0.6,
                                        ),
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

          // if (_descripcionError)
          //   const Padding(
          //     padding: EdgeInsets.only(left: 16, bottom: 4),
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: Text(
          //         'Ingresa los detalles',
          //         style: TextStyle(color: Colors.red, fontSize: 13),
          //       ),
          //     ),
          //   ),
          if (_isExpanded &&
              (_images.isNotEmpty || _videos.isNotEmpty || _audios.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // if (_descripcionError)
                  //   const Padding(
                  //     padding: EdgeInsets.only(left: 16, bottom: 4),
                  //     child: Align(
                  //       alignment: Alignment.centerLeft,
                  //       child: Text(
                  //         'Ingresa los detalles',
                  //         style: TextStyle(color: Colors.red, fontSize: 13),
                  //       ),
                  //     ),
                  //   ),
                  if (_audios.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _audios.length,
                      itemBuilder: (context, index) {
                        return AudioBubble(
                          audioPlayer: _audioPlayers[index],
                          onRemove: () => _removeAudio(index),
                        );
                      },
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
                                        color: Colors.red.withAlpha(
                                          (0.8 * 255).toInt(),
                                        ),
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
                                        color: Colors.red.withAlpha(
                                          (0.8 * 255).toInt(),
                                        ),
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

                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onLongPressStart: (_) => _startRecording(),
                      onLongPressEnd: (_) => _stopRecording(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedBuilder(
                          animation: _micScaleAnimation,
                          builder: (context, child) {
                            return AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      _micScaleAnimation.value *
                                      (_isRecording
                                          ? _pulseAnimation.value
                                          : 1.0),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          _isRecording
                                              ? Colors.red
                                              : const Color(0xFF3645f5),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow:
                                          _isRecording
                                              ? [
                                                BoxShadow(
                                                  color: Colors.red.withAlpha((0.3 * 255).toInt()),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
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
    _audioRecorder.dispose();

    _micAnimationController.dispose();
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();

    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }
}

class AudioBubble extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final VoidCallback onRemove;

  const AudioBubble({
    super.key,
    required this.audioPlayer,
    required this.onRemove,
  });

  @override
  AudioBubbleState createState() => AudioBubbleState();
}

class AudioBubbleState extends State<AudioBubble> {
  String _formatDuration(Duration? d) {
    if (d == null) return "00:00";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.25 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: widget.audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: widget.audioPlayer.play,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  onPressed: widget.audioPlayer.pause,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay, color: Colors.white),
                  onPressed: () => widget.audioPlayer.seek(Duration.zero),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }
            },
          ),
          const SizedBox(width: 8),

          Expanded(
            child: StreamBuilder<Duration?>(
              stream: widget.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = widget.audioPlayer.duration ?? Duration.zero;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble().clamp(
                        0.0,
                        duration.inMilliseconds.toDouble(),
                      ),
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        widget.audioPlayer.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withAlpha((0.3 * 255).toInt()),
                    ),
                    Text(
                      "${_formatDuration(position)} / ${_formatDuration(duration)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
