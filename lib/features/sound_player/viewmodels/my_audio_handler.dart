import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final audioHandlerProvider = Provider<Future<MyAudioHandler>>((ref) async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.splat.mytune.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
});

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  AudioPlayer player = AudioPlayer();


  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    player.playerStateStream.listen((playerState) async {
      playbackState.add(playbackState.value.copyWith(
        playing: playerState.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState]!,
      ));
    });
    player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });
  }


  Future<void> fadeIn(int fadeInSeconds) async {
    if (fadeInSeconds == 0) {
      await player.setVolume(1.0);
      print('[FadeIn] Set volume: 1.0 (no fade)');
      return;
    }
    await player.setVolume(0.0);
    print('[FadeIn] Set volume: 0.0 (start fade)');
    final steps = 20;
    final stepDuration = Duration(milliseconds: (fadeInSeconds * 1000 ~/ steps));
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      final v = i / steps;
      await player.setVolume(v);
      print('[FadeIn] Set volume: ' + v.toStringAsFixed(2));
    }
  }

  Future<void> fadeOut(int fadeOutSeconds) async {
    if (fadeOutSeconds == 0) {
      await player.setVolume(0.0);
      return;
    }
    final steps = 20;
    final stepDuration = Duration(milliseconds: (fadeOutSeconds * 1000 ~/ steps));
    for (int i = steps - 1; i >= 0; i--) {
      await Future.delayed(stepDuration);
      await player.setVolume(i / steps);
    }
    await player.setVolume(0.0);
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);
}
