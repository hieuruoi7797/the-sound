import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class SoundPlayerState {
  final String? audioName;
  final String? imageUrl;
  final String? audioUrl;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final bool showPlayer;
  final bool isLiked;

  SoundPlayerState({
    this.audioName,
    this.imageUrl,
    this.audioUrl,
    this.currentTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isPlaying = false,
    this.showPlayer = false,
    this.isLiked = false,
  });

  SoundPlayerState copyWith({
    String? audioName,
    String? imageUrl,
    String? audioUrl,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    bool? showPlayer,
    bool? isLiked,
  }) {
    return SoundPlayerState(
      audioName: audioName ?? this.audioName,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  Timer? _timer;

  SoundPlayerViewModel() : super(SoundPlayerState());

  Future<void> setAudio({
    required String audioName,
    required String imageUrl,
    String audioDirectUrl = '',
    String googleDriveUrl = '',
  }) async {
    final directUrl = audioDirectUrl.isEmpty ? _googleDriveToDirect(googleDriveUrl) : audioDirectUrl;
    await _audioPlayer.setUrl(directUrl);
    final duration = _audioPlayer.duration ?? Duration.zero;
    state = state.copyWith(
      audioName: audioName,
      imageUrl: imageUrl,
      audioUrl: directUrl,
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
    _audioPlayer.play();
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
    _audioPlayer.pause();
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
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
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(currentTime: pos);
    });
  }

  void _listenToPlayerState() {
    _playerStateSub?.cancel();
    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        pause();
        _audioPlayer.seek(Duration.zero);
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

  void showPlayer(){
    setAudio(
                    audioName: 'Ocean Waves',
                    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                    googleDriveUrl: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
                  );
    state = state.copyWith(showPlayer: true);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Provider for the current tab index
final navigatorViewModelProvider = StateNotifierProvider<NavigatorViewModel, int>((ref) {
  return NavigatorViewModel();
});

class NavigatorViewModel extends StateNotifier<int> {
  NavigatorViewModel() : super(0); // Default to first tab (Home)
  
  void setTab(int index) {
    state = index;
  }
} 