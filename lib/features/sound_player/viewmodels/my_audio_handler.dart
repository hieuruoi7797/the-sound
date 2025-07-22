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
  int fadeInSeconds = 5;
  int fadeOutSeconds = 5;

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    player.playerStateStream.listen((playerState) {
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

  void setFadeInSeconds(int seconds) {
    fadeInSeconds = seconds;
  }

  void setFadeOutSeconds(int seconds) {
    fadeOutSeconds = seconds;
  }

  Future<void> fadeIn() async {
    if (fadeInSeconds == 0) {
      await player.setVolume(1.0);
      return;
    }
    await player.setVolume(0.0);
    final steps = 20;
    final stepDuration = Duration(milliseconds: (fadeInSeconds * 1000 ~/ steps));
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      await player.setVolume(i / steps);
    }
  }

  Future<void> fadeOut() async {
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

  Future<void> playMedia(String url, {String? title, String? artUri}) async {
    await player.setUrl(url);
    mediaItem.add(MediaItem(
      id: url,
      title: title ?? 'Audio',
      artUri: artUri != null ? Uri.parse(artUri) : null,
      duration: player.duration,
    ));
    play();
  }

  @override
  Future<void> play() async {
    await player.play();
    await fadeIn();
  }

  @override
  Future<void> pause() async {
    await fadeOut();
    await player.pause();
  }

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);
}
