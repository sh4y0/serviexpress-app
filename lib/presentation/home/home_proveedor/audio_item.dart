import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class AudioItem extends StatefulWidget {
  final String url;
  const AudioItem({super.key, required this.url});

  @override
  State<AudioItem> createState() => _AudioItemState();
}

class _AudioItemState extends State<AudioItem> {
  late final AudioPlayer _player;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(
    Duration.zero,
  );

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _player.setLoopMode(LoopMode.off);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.url)));

      final duration = await _player.setUrl(widget.url, preload: true);

      if (duration != null) {
        _durationNotifier.value = duration;
      }

      _positionSub = _player.positionStream.listen((position) {
        if (mounted) _positionNotifier.value = position;
      });

      _playerStateSub = _player.playerStateStream.listen((state) {
        if (!mounted) return;

        if (state.processingState == ProcessingState.completed) {
          _isCompleted = true;
          _player.pause();
          _player.seek(Duration.zero);
          _isPlaying.value = false;
        } else {
          _isCompleted = false;
          _isPlaying.value = state.playing;
        }
      });
    } catch (e) {
      debugPrint("Error al cargar el audio: $e");
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    _isPlaying.dispose();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.bgProp,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isPlaying,
            builder: (context, playing, _) {
              return IconButton(
                iconSize: 32,
                onPressed: () async {
                  if (_isCompleted) {
                    await _player.seek(Duration.zero);
                    _isCompleted = false;
                    await _player.play();
                  } else if (playing) {
                    await _player.pause();
                  } else {
                    await _player.play();
                  }
                },

                icon: Icon(
                  (playing && !_isCompleted) ? Icons.pause : Icons.play_arrow,
                  color: AppColor.bgAll,
                ),
              );
            },
          ),
          ValueListenableBuilder2<Duration, Duration>(
            firstNotifier: _positionNotifier,
            secondNotifier: _durationNotifier,
            builder: (context, position, duration) {
              if (duration.inMilliseconds == 0) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150,
                    child: Slider(
                      thumbColor: AppColor.bgCircle,
                      secondaryActiveColor: Colors.red,
                      activeColor: AppColor.bgAll,
                      inactiveColor: AppColor.dotColor,
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      value:
                          position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: AppColor.bgCircle,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        " / ",
                        style: TextStyle(color: AppColor.bgCircle),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: AppColor.bgCircle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> firstNotifier;
  final ValueNotifier<B> secondNotifier;
  final Widget Function(BuildContext, A, B) builder;
  const ValueListenableBuilder2({
    super.key,
    required this.firstNotifier,
    required this.secondNotifier,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: firstNotifier,
      builder: (context, valueA, _) {
        return ValueListenableBuilder<B>(
          valueListenable: secondNotifier,
          builder: (context, valueB, _) => builder(context, valueA, valueB),
        );
      },
    );
  }
}
