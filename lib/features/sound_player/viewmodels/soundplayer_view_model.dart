import 'dart:async';
import 'dart:ui';

import 'package:mytune/features/sound_player/viewmodels/my_audio_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound_model.dart';
import '../../timer/viewmodels/timer_setting_view_model.dart';

class SoundPlayerState {
  final SoundModel? sound;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final bool showPlayer;
  final bool isLiked;
  final Duration timerDuration;
  SoundPlayerState({
    this.sound,
    this.currentTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isPlaying = false,
    this.showPlayer = false,
    this.isLiked = false,
    this.timerDuration = Duration.zero,
  });

  SoundPlayerState copyWith({
    SoundModel? sound,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    bool? showPlayer,
    bool? isLiked,
    Duration? timerDuration,
  }) {
    return SoundPlayerState(
      sound: sound ?? this.sound,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      showPlayer: showPlayer ?? this.showPlayer,
      isLiked: isLiked ?? this.isLiked,
      timerDuration: timerDuration ?? this.timerDuration,
    );
  }
}

final soundPlayerProvider = StateNotifierProvider<SoundPlayerViewModel, SoundPlayerState>((ref) {
  final audioHandlerFuture = ref.read(audioHandlerProvider);
  return SoundPlayerViewModel(audioHandlerFuture, ref);
});

class SoundPlayerViewModel extends StateNotifier<SoundPlayerState> {
  final Future<MyAudioHandler> _audioHandlerFuture;
  final Ref _ref;
  MyAudioHandler audioHandler = MyAudioHandler();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  Timer? _stopTimer;
  Duration? _currentAudioDuration;
  VoidCallback? _timerListenerDispose;

  SoundPlayerViewModel(this._audioHandlerFuture, this._ref) : super(SoundPlayerState()) {
    _init();
  }

  Future<void> _init() async {
    audioHandler = await _audioHandlerFuture;
    _listenToTimerDurationChanges();
  }

  void _listenToTimerDurationChanges() {
    _timerListenerDispose?.call();

    _timerListenerDispose = _ref.listen<Duration>(
      timerSettingViewModelProvider,
      (prevDuration, newDuration) {
        print('Timer duration changed from $prevDuration to $newDuration');
        state = state.copyWith(timerDuration: newDuration);
        if (state.isPlaying) {
          _scheduleStopTimer(newDuration);
        }
      },
      fireImmediately: true,
    ).close;
  }

  void _scheduleStopTimer(Duration duration) {
    _stopTimer?.cancel();
    if (duration.inMilliseconds > 0) {
      final Duration timeUntilStop = duration - audioHandler.player.position;
      if (timeUntilStop > Duration.zero) {
        _stopTimer = Timer(timeUntilStop, () {
          print('Timer finished, stopping playback.');
          pause();
          audioHandler.player.seek(Duration.zero);
        });
        print('Stop timer scheduled for $timeUntilStop');
      } else {
        print('Timer duration less than current position, stopping immediately.');
        pause();
        audioHandler.player.seek(Duration.zero);
      }
    }
  }

  Future<void> setAudio(SoundModel? sound) async {
    if (sound == null) return;

    _stopTimer?.cancel();

    final directUrl = sound.audioDirectUrl.isNotEmpty ?
     sound.audioDirectUrl :
      _googleDriveToDirect(sound.googleDriveUrl);

    final tempPlayer = AudioPlayer();
    try {
      await tempPlayer.setUrl(directUrl);
      _currentAudioDuration = tempPlayer.duration;
    } finally {
      tempPlayer.dispose();
    }

    if (_currentAudioDuration == null || _currentAudioDuration!.inMilliseconds == 0) {
        print("Could not get audio duration or duration is zero.");
        state = state.copyWith(
          sound: sound,
          totalDuration: Duration.zero,
          currentTime: Duration.zero,
          showPlayer: true,
          isPlaying: false,
        );
        return;
    }

    final currentTimerDuration = _ref.read(timerSettingViewModelProvider);

    int loopCount = 1;
    if (currentTimerDuration.inMilliseconds > 0 && _currentAudioDuration!.inMilliseconds > 0) {
      loopCount = (currentTimerDuration.inMilliseconds / _currentAudioDuration!.inMilliseconds).ceil();
      if (loopCount == 0 && currentTimerDuration.inMilliseconds > 0) {
        loopCount = 1;
      }
    }

    if (currentTimerDuration.inMilliseconds == 0) {
      loopCount = 1;
    }

    final playlist = ConcatenatingAudioSource(children: [
      for (int i = 0; i < loopCount; i++)
        AudioSource.uri(Uri.parse(directUrl))
    ]);

    await audioHandler.player.setAudioSource(playlist, initialPosition: Duration.zero);

    final totalPlaylistDuration = audioHandler.player.duration;

    state = state.copyWith(
      sound: sound,
      totalDuration: totalPlaylistDuration ?? Duration.zero,
      currentTime: Duration.zero,
      showPlayer: true,
      isPlaying: false,
      timerDuration: currentTimerDuration,
    );

    play();
    _listenToPosition();
    _listenToPlayerState();

    _scheduleStopTimer(currentTimerDuration);
  }

  void play() {
    if (!state.isPlaying) {
      state = state.copyWith(isPlaying: true);
      audioHandler.play();
      _scheduleStopTimer(state.timerDuration);
    }
  }

  void pause() {
    if (state.isPlaying) {
      state = state.copyWith(isPlaying: false);
      audioHandler.pause();
      _stopTimer?.cancel();
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void like() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void collapse() {
    state = state.copyWith(showPlayer: false);
    pause();
  }

  void _listenToPosition() {
    _positionSub?.cancel();
    _positionSub = audioHandler.player.positionStream.listen((pos) {
      state = state.copyWith(currentTime: pos);
    });
  }

  void _listenToPlayerState() {
    _playerStateSub?.cancel();
    _playerStateSub = audioHandler.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        print('Playlist completed.');
        if (state.isPlaying) {
          pause();
          audioHandler.player.seek(Duration.zero);
        }
      }
    });
  }

  String _googleDriveToDirect(String url) {
    final reg = RegExp(r"/d/([\w-]+)");
    final match = reg.firstMatch(url);
    if (match != null) {
      final id = match.group(1);
      return "https://drive.google.com/uc?export=download&id=$id";
    }
    final uri = Uri.parse(url);
    final id = uri.queryParameters['id'];
    if (id != null) {
      return "https://drive.google.com/uc?export=download&id=$id";
    }
    return url;
  }

  void showPlayer({SoundModel? sound}) async {
    if (state.sound == null && sound != null) {
      await setAudio(sound);
    } else if (state.sound == null && sound == null) {
      
      print("showPlayer called with no sound and no sound loaded.");
      return;
    } else if (state.sound != null && sound != null && state.sound != sound) {
      print("Loading new sound: ${sound.audioName}");
      await setAudio(sound);
    }
    state = state.copyWith(showPlayer: true);
    play();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _stopTimer?.cancel();
    _timerListenerDispose?.call();
    audioHandler.player.dispose();
    super.dispose();
  }
}