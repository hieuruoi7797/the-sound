import 'dart:async';

import 'package:flutter_mvvm_app/features/sound_player/viewmodels/my_audio_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound_model.dart';

class SoundPlayerState {
  final SoundModel? sound;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final bool showPlayer;
  final bool isLiked;

  SoundPlayerState({
    this.sound,
    this.currentTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isPlaying = false,
    this.showPlayer = false,
    this.isLiked = false,
  });

  SoundPlayerState copyWith({
    SoundModel? sound,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    bool? showPlayer,
    bool? isLiked,
  }) {
    return SoundPlayerState(
      sound: sound ?? this.sound,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      showPlayer: showPlayer ?? this.showPlayer,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

final soundPlayerProvider = StateNotifierProvider<SoundPlayerViewModel, SoundPlayerState>((ref) {
  return SoundPlayerViewModel();
});

class SoundPlayerViewModel extends StateNotifier<SoundPlayerState> {
  MyAudioHandler audioHandler = MyAudioHandler();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  Timer? _timer;

  SoundPlayerViewModel() : super(SoundPlayerState());

  Future<void> setAudio(SoundModel? sound) async {
    if (sound == null) return;
    final directUrl = sound.audioDirectUrl.isNotEmpty ?
     sound.audioDirectUrl :
      _googleDriveToDirect(sound.googleDriveUrl);
    await audioHandler.player.setUrl(directUrl);
    final duration = audioHandler.player.duration ;
    state = state.copyWith(
      sound: sound,
      totalDuration: duration,
      currentTime: Duration.zero,
      showPlayer: true,
      isPlaying: false,
    );
    _listenToPosition();
    _listenToPlayerState();
  }

  void play() {
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
    audioHandler.pause();
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      if (state.sound != null) {
      audioHandler.playMedia(
        state.sound!.audioDirectUrl.isNotEmpty?state.sound!.audioDirectUrl: _googleDriveToDirect(state.sound!.googleDriveUrl),title: "AAA",artUri: state.sound!.imageUrl);
      play();
      }
    }
  }

  void setTimer(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      pause();
    });
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
        pause();
        audioHandler.player.seek(Duration.zero);
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
    // fallback for ?id= links
    final uri = Uri.parse(url);
    final id = uri.queryParameters['id'];
    if (id != null) {
      return "https://drive.google.com/uc?export=download&id=$id";
    }
    return url;
  }

  void showPlayer({SoundModel? sound}) {
    setAudio(sound ?? SoundModel(
      audioName: 'AAA', 
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e', 
      audioDirectUrl: '',
      googleDriveUrl: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
      description: ''));


    state = state.copyWith(showPlayer: true);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _timer?.cancel();
    // audioHandler.player.dispose();
    super.dispose();
  }
}