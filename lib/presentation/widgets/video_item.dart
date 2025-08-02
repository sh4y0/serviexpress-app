import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  final String url;
  const VideoItem({super.key, required this.url});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> _initializedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isPlayingInDialogNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    try {
      await _controller.initialize();
      _controller.setVolume(0);
      _controller.pause();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializedNotifier.value = true;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializedNotifier.value = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _initializedNotifier.dispose();
    _isPlayingInDialogNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _initializedNotifier,
      builder: (context, initialized, _) {
        if (!initialized) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        return GestureDetector(
          onTap: _showVideoDialog,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              const Icon(
                Icons.play_circle_outlined,
                size: 40,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoDialog() {
    _isPlayingInDialogNotifier.value = true;
    _controller.setVolume(1.0);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(16),
            child: _VideoViewerDialog(
              controller: _controller,
              onClose: () {
                _isPlayingInDialogNotifier.value = false;
                _controller.setVolume(0);
                _controller.pause();
              },
            ),
          ),
    ).then((_) {
      if (_isPlayingInDialogNotifier.value) {
        _isPlayingInDialogNotifier.value = false;
        _controller.setVolume(0);
        _controller.pause();
      }
    });
  }
}

class _VideoViewerDialog extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClose;
  const _VideoViewerDialog({required this.controller, required this.onClose});

  @override
  State<_VideoViewerDialog> createState() => __VideoViewerDialogState();
}

class __VideoViewerDialogState extends State<_VideoViewerDialog> {
  late final ValueNotifier<bool> _isPlayingNotifier;
  late final ValueNotifier<bool> _isInitializedNotifier;
  late final ValueNotifier<bool> _showControlsNotifier;

  bool _initialPlayTriggered = false;

  @override
  void initState() {
    super.initState();
    _isPlayingNotifier = ValueNotifier(widget.controller.value.isPlaying);
    _isInitializedNotifier = ValueNotifier(
      widget.controller.value.isInitialized,
    );
    _showControlsNotifier = ValueNotifier(true);

    widget.controller.addListener(_updateNotifiers);

    if (widget.controller.value.isInitialized && !_initialPlayTriggered) {
      _initialPlayTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.play();
        _isPlayingNotifier.value = true;
      });
    }
  }

  void _updateNotifiers() {
    if (_isPlayingNotifier.value != widget.controller.value.isPlaying) {
      _isPlayingNotifier.value = widget.controller.value.isPlaying;
    }
    if (_isInitializedNotifier.value != widget.controller.value.isInitialized) {
      _isInitializedNotifier.value = widget.controller.value.isInitialized;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateNotifiers);
    _isPlayingNotifier.dispose();
    _isInitializedNotifier.dispose();
    _showControlsNotifier.dispose();
    widget.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitializedNotifier,
      builder: (context, isInitialized, _) {
        if (!isInitialized) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: _isPlayingNotifier,
          builder: (context, isPlaying, _) {
            return GestureDetector(
              onTap: () {
                _showControlsNotifier.value = !_showControlsNotifier.value;
              },
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(widget.controller),
                    VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColor.btnColor,
                        bufferedColor: AppColor.loginSelect,
                        backgroundColor: AppColor.bgMsgUser,
                      ),
                    ),

                    ValueListenableBuilder<bool>(
                      valueListenable: _showControlsNotifier,
                      builder: (context, showControls, _) {
                        if (!showControls) return const SizedBox.shrink();

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Stack(
                              children: [
                                AnimatedBuilder(
                                  animation: widget.controller,
                                  builder: (context, child) {
                                    final position =
                                        widget.controller.value.position;
                                    final duration =
                                        widget.controller.value.duration;

                                    String formatDuration(Duration d) {
                                      String twoDigits(int n) =>
                                          n.toString().padLeft(2, '0');
                                      final minutes = twoDigits(
                                        d.inMinutes.remainder(60),
                                      );
                                      final seconds = twoDigits(
                                        d.inSeconds.remainder(60),
                                      );
                                      return '${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formatDuration(position),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  final newPosition =
                                                      widget
                                                          .controller
                                                          .value
                                                          .position -
                                                      const Duration(
                                                        seconds: 10,
                                                      );
                                                  widget.controller.seekTo(
                                                    newPosition > Duration.zero
                                                        ? newPosition
                                                        : Duration.zero,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.replay_10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                iconSize: 40,
                                                onPressed: _togglePlayPause,
                                                icon: Icon(
                                                  isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  final max =
                                                      widget
                                                          .controller
                                                          .value
                                                          .duration;
                                                  final newPos =
                                                      widget
                                                          .controller
                                                          .value
                                                          .position +
                                                      const Duration(
                                                        seconds: 10,
                                                      );
                                                  widget.controller.seekTo(
                                                    newPos < max ? newPos : max,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.forward_10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            formatDuration(duration),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }
}

// Positioned.fill(
//   child: GestureDetector(onTap: _togglePlayPause),
// ),
