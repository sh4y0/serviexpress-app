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
  final AudioRecorder _audioRecorder = AudioRecorder();

  final ValueNotifier<List<File>> imagesNotifier = ValueNotifier([]);
  final ValueNotifier<List<File>> videosNotifier = ValueNotifier([]);
  final ValueNotifier<List<File>> audiosNotifier = ValueNotifier([]);
  final ValueNotifier<List<AudioPlayer>> audioPlayersNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> isExpandedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> descripcionErrorNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);
  final ValueNotifier<int> recordingSecondsNotifier = ValueNotifier(0);

  late AnimationController _micAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _micScaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  String get descripcionText => descripcionController.text;
  List<File> get images => imagesNotifier.value;
  List<File> get videos => videosNotifier.value;
  List<File> get audios => audiosNotifier.value;

  final ValueNotifier<bool> isTextFieldReadOnlyNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(focusNodeSegundo);
      }
    });
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

  Future<void> setInitialData(
    String categoria,
    String description,
    List<File> initialImages,
    List<File> initialVideos,
    List<File> initialAudios,
  ) async {
    if (mounted) {
      descripcionController.text = description;
      imagesNotifier.value = initialImages;
      videosNotifier.value = initialVideos;

      for (var player in audioPlayersNotifier.value) {
        player.dispose();
      }

      final newPlayers = <AudioPlayer>[];
      for (var audioFile in initialAudios) {
        final player = AudioPlayer();
        try {
          await player.setFilePath(audioFile.path);
          newPlayers.add(player);
        } catch (e) {
          debugPrint(
            "Error al cargar el archivo de audio ${audioFile.path}: $e",
          );
        }
      }

      audioPlayersNotifier.value = newPlayers;
      audiosNotifier.value = initialAudios;

      isExpandedNotifier.value =
          description.isNotEmpty ||
          initialImages.isNotEmpty ||
          initialVideos.isNotEmpty ||
          initialAudios.isNotEmpty;
    }
  }

  Future<void> _pickMultiImageFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty && mounted) {
      final newImages = List<File>.from(imagesNotifier.value)
        ..addAll(pickedFiles.map((xfile) => File(xfile.path)));
      imagesNotifier.value = newImages;
      isExpandedNotifier.value = true;
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final newImages = List<File>.from(imagesNotifier.value)
        ..add(File(image.path));
      imagesNotifier.value = newImages;
      isExpandedNotifier.value = true;
    }
  }

  Future<void> _pickMultiVideoFromGallery() async {
    final List<XFile> pickedFiles = await _picker.pickMultipleMedia(
      requestFullMetadata: false,
    );
    if (pickedFiles.isNotEmpty) {
      final selectedVideos =
          pickedFiles
              .where(
                (file) =>
                    file.path.toLowerCase().endsWith('.mp4') ||
                    file.path.toLowerCase().endsWith('.mov'),
              )
              .map((file) => File(file.path))
              .toList();
      if (selectedVideos.isNotEmpty) {
        final newVideos = List<File>.from(videosNotifier.value)
          ..addAll(selectedVideos);
        videosNotifier.value = newVideos;
        isExpandedNotifier.value = true;
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(
          dir.path,
          'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
        );
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        isRecordingNotifier.value = true;
        recordingSecondsNotifier.value = 0;
        isExpandedNotifier.value = true;

        _micAnimationController.forward();
        _pulseAnimationController.repeat(reverse: true);
        _waveAnimationController.repeat();
        _startRecordingTimer();
      }
    } catch (e) {
      debugPrint('Error al iniciar grabación: $e');
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (isRecordingNotifier.value && mounted) {
        recordingSecondsNotifier.value++;
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

        final newAudios = List<File>.from(audiosNotifier.value)..add(audioFile);
        final newPlayers = List<AudioPlayer>.from(audioPlayersNotifier.value)
          ..add(player);

        audiosNotifier.value = newAudios;
        audioPlayersNotifier.value = newPlayers;
      }
    } catch (e) {
      debugPrint('Error al detener grabación: $e');
    } finally {
      if (mounted) {
        isRecordingNotifier.value = false;
      }
      _micAnimationController.reverse();
      _pulseAnimationController.stop();
      _waveAnimationController.stop();
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      final newVideos = List<File>.from(videosNotifier.value)
        ..add(File(video.path));
      videosNotifier.value = newVideos;
      isExpandedNotifier.value = true;
    }
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(imagesNotifier.value)..removeAt(index);
    imagesNotifier.value = newImages;
    _checkIfStillExpanded();
  }

  void _removeVideo(int index) {
    final newVideos = List<File>.from(videosNotifier.value)..removeAt(index);
    videosNotifier.value = newVideos;
    _checkIfStillExpanded();
  }

  void _removeAudio(int index) {
    final newPlayers = List<AudioPlayer>.from(audioPlayersNotifier.value);
    newPlayers[index].dispose();
    newPlayers.removeAt(index);
    audioPlayersNotifier.value = newPlayers;

    final newAudios = List<File>.from(audiosNotifier.value)..removeAt(index);
    audiosNotifier.value = newAudios;

    _checkIfStillExpanded();
  }

  void _checkIfStillExpanded() {
    if (descripcionController.text.isEmpty &&
        imagesNotifier.value.isEmpty &&
        videosNotifier.value.isEmpty &&
        audiosNotifier.value.isEmpty) {
      isExpandedNotifier.value = false;
    }
  }

  void clearForm() {
    descripcionController.clear();
    imagesNotifier.value = [];
    videosNotifier.value = [];

    for (var player in audioPlayersNotifier.value) {
      player.dispose();
    }
    audioPlayersNotifier.value = [];
    audiosNotifier.value = [];

    isExpandedNotifier.value = false;
  }

  bool hasContent() {
    return descripcionController.text.isNotEmpty ||
        imagesNotifier.value.isNotEmpty ||
        videosNotifier.value.isNotEmpty ||
        audiosNotifier.value.isNotEmpty;
  }

  void mostrarErrorDescripcion() {
    descripcionErrorNotifier.value = true;
  }

  String _formatRecordingTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildRecordingIndicator() {
    return ValueListenableBuilder<int>(
      valueListenable: recordingSecondsNotifier,
      builder: (context, seconds, _) {
        return AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  'Grabando... ${_formatRecordingTime(seconds)}',
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
                        (math.sin(_waveAnimation.value * math.pi * 2 + index) *
                            8),
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
      },
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(38, 48, 137, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: const Text(
                  'Tomar Foto',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text(
                  'Subir Fotos de la Galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMultiImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white70),
                title: const Text(
                  'Grabar Video',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _recordVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.white70),
                title: const Text(
                  'Subir Videos de la Galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickMultiVideoFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: descripcionErrorNotifier,
      builder: (context, hasError, child) {
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
            border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 2,
              top: 8,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: isRecordingNotifier,
              builder: (context, isRecording, _) {
                return isRecording
                    ? _buildRecordingIndicator()
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: SvgCache.getIconSvg(
                            'assets/icons/ic_message_form.svg',
                            color:
                                descripcionErrorNotifier.value
                                    ? Colors.red
                                    : const Color.fromRGBO(194, 215, 255, 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isTextFieldReadOnlyNotifier,
                            builder: (context, isReadOnly, child) {
                              return TextField(
                                controller: descripcionController,
                                focusNode: focusNodeSegundo,
                                readOnly: isReadOnly,
                                maxLines: null,
                                showCursor: true,
                                keyboardType: TextInputType.multiline,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      "Cuéntanos con más detalle qué necesitas...",
                                  hintStyle: TextStyle(
                                    color:
                                        descripcionErrorNotifier.value
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
                                  if (isTextFieldReadOnlyNotifier.value) {
                                    isTextFieldReadOnlyNotifier.value = false;
                                  }
                                  if (!isExpandedNotifier.value) {
                                    isExpandedNotifier.value = true;
                                  }
                                },
                                onChanged: (text) {
                                  if (text.isNotEmpty) {
                                    descripcionErrorNotifier.value = false;
                                    if (!isExpandedNotifier.value) {
                                      isExpandedNotifier.value = true;
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: descripcionErrorNotifier,
            builder: (context, hasError, _) {
              if (!hasError) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingresa los detalles',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isExpandedNotifier,
            builder: (context, isExpanded, _) {
              if (!isExpanded) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ValueListenableBuilder<List<File>>(
                      valueListenable: audiosNotifier,
                      builder: (context, audios, _) {
                        if (audios.isEmpty) return const SizedBox.shrink();
                        return ValueListenableBuilder<List<AudioPlayer>>(
                          valueListenable: audioPlayersNotifier,
                          builder: (context, players, _) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: audios.length,
                              itemBuilder:
                                  (context, index) => AudioBubble(
                                    audioPlayer: players[index],
                                    onRemove: () => _removeAudio(index),
                                  ),
                            );
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<List<File>>(
                      valueListenable: imagesNotifier,
                      builder: (context, images, _) {
                        if (images.isEmpty) return const SizedBox.shrink();
                        return SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
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
                                        images[index],
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
                        );
                      },
                    ),
                    ValueListenableBuilder<List<File>>(
                      valueListenable: videosNotifier,
                      builder: (context, videos, _) {
                        if (videos.isEmpty) return const SizedBox.shrink();
                        return SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videos.length,
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
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromRGBO(194, 215, 255, 1),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    onPressed: () => _showAttachmentMenu(context),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Color.fromRGBO(54, 69, 245, 1),
                    ),
                    label: const Text(
                      "Tomar o subir",
                      style: TextStyle(
                        color: Color.fromRGBO(54, 69, 245, 1),
                        fontSize: 13,
                      ),
                    ),
                  ),
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
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isRecordingNotifier,
                          builder: (context, isRecording, _) {
                            return AnimatedBuilder(
                              animation: Listenable.merge([
                                _micScaleAnimation,
                                _pulseAnimation,
                              ]),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      _micScaleAnimation.value *
                                      (isRecording
                                          ? _pulseAnimation.value
                                          : 1.0),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          isRecording
                                              ? Colors.red
                                              : const Color(0xFF3645f5),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow:
                                          isRecording
                                              ? [
                                                BoxShadow(
                                                  color: Colors.red.withAlpha(
                                                    (0.3 * 255).toInt(),
                                                  ),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Icon(
                                      isRecording ? Icons.stop : Icons.mic,
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
    for (var player in audioPlayersNotifier.value) {
      player.dispose();
    }
    imagesNotifier.dispose();
    videosNotifier.dispose();
    audiosNotifier.dispose();
    audioPlayersNotifier.dispose();
    isExpandedNotifier.dispose();
    descripcionErrorNotifier.dispose();
    isRecordingNotifier.dispose();
    recordingSecondsNotifier.dispose();
    isTextFieldReadOnlyNotifier.dispose();
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
                      inactiveColor: Colors.white.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
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
