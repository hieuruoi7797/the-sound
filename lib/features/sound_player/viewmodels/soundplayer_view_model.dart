import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mytune/core/constants/app_strings.dart';
import 'package:mytune/features/sound_player/viewmodels/my_audio_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound_model.dart';
import '../../timer/viewmodels/timer_setting_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/viewmodels/settings_view_model.dart';
import 'package:mytune/core/network/network_providers.dart';

class SoundPlayerState {
  final SoundModel? sound;
  final Duration currentTime;
  final Duration totalDuration;
  final bool isPlaying;
  final bool showPlayer;
  final bool isLiked;
  final Duration timerDuration;
  final bool isLoading;

  SoundPlayerState({
    this.sound,
    this.currentTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isPlaying = false,
    this.showPlayer = false,
    this.isLiked = false,
    this.timerDuration = Duration.zero,
    this.isLoading = false,
  });

  SoundPlayerState copyWith({
    SoundModel? sound,
    Duration? currentTime,
    Duration? totalDuration,
    bool? isPlaying,
    bool? showPlayer,
    bool? isLiked,
    Duration? timerDuration,
    bool? isLoading,
  }) {
    return SoundPlayerState(
      sound: sound ?? this.sound,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      showPlayer: showPlayer ?? this.showPlayer,
      isLiked: isLiked ?? this.isLiked,
      timerDuration: timerDuration ?? this.timerDuration,
      isLoading: isLoading ?? this.isLoading,
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
  VoidCallback? _connectivityListenerDispose;
  Timer? _stopTimer;
  Duration? _currentAudioDuration;
  VoidCallback? _timerListenerDispose;
  List<SoundModel> _favorites = [];
  int fadeInSeconds = 0;
  int fadeOutSeconds = 0;
  int _loadToken = 0;


  List<SoundModel> get favorites => List.unmodifiable(_favorites);

  SoundPlayerViewModel(this._audioHandlerFuture, this._ref) : super(SoundPlayerState()) {
    _init();
    _listenToFadeSettings();
    _listenToConnectivity();
  }

  Future<void> _init() async {
    audioHandler = await _audioHandlerFuture;
    _listenToTimerDurationChanges();
    await _loadFavorites();
  }

  void _listenToConnectivity() {
    _connectivityListenerDispose?.call();
    _connectivityListenerDispose = _ref.listen<AsyncValue<bool>>(
      connectivityStatusProvider,
      (prev, next) {
        next.whenData((isConnected) {
          if (isConnected) {
            print('[SoundPlayer] Internet connection restored, processing queue...');
            _processQueuedRequests();
          }
        });
      },
    ).close;
  }

  void _processQueuedRequests() async {
    final queueService = _ref.read(requestQueueServiceProvider);
    await queueService.processQueue();
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

  void _listenToFadeSettings() {
    _ref.listen<SettingsState>(
      settingsViewModelProvider,
      (prev, next) {
        fadeInSeconds = next.fadeInSeconds;
        fadeOutSeconds = next.fadeOutSeconds;
      },
      fireImmediately: true,
    );
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

  Future<void> setAudio(SoundModel? sound, int? loadToken) async {
    if (sound == null) return;

    _stopTimer?.cancel();

    // Check connectivity before attempting to load
    final connectivityService = _ref.read(connectivityServiceProvider);
    final isConnected = await connectivityService.checkConnectivity();
    
    if (!isConnected) {
      print('[SoundPlayer] No internet connection. Queuing audio request...');
      final queueService = _ref.read(requestQueueServiceProvider);
      
      // Queue the request for retry when connection is restored
      await queueService.queueRequest(
        resourceType: 'audio',
        resourceUrl: sound.url,
        request: () => setAudio(sound, loadToken),
      );
      
      // Show user feedback
      Fluttertoast.showToast(
        msg: "No internet connection. Audio queued for loading.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    String directUrl;
    
    try {
      
      // Tạo đường dẫn tới file trên Firebase Storage theo định dạng sounds/{soundId}.wav
      final storagePath = 'sounds/${sound.soundId}.wav';
      
      try {
        // Lấy download URL từ Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(storagePath);
        directUrl = await ref.getDownloadURL();
        print("Firebase Storage URL: $directUrl");
      } catch (e) {
        print("Error getting Firebase Storage URL: $e");
        // Fallback to the original URL if Firebase Storage fails
        directUrl = sound.url;
        print("Fallback to original URL: $directUrl");
      }
    } catch (e) {
      print("Firebase initialization error: $e");
      
      // Queue if error occurs (likely no connectivity)
      final queueService = _ref.read(requestQueueServiceProvider);
      await queueService.queueRequest(
        resourceType: 'audio',
        resourceUrl: sound.url,
        request: () => setAudio(sound, loadToken),
      );
      
      Fluttertoast.showToast(
        msg: "Failed to load audio. Queued for retry.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }
    
    final tempPlayer = AudioPlayer();
    try {
      await tempPlayer.setUrl(directUrl);
       // Save to recents
      await _addToRecents(sound);

      _currentAudioDuration = tempPlayer.duration;
    } on Exception catch (e) {
      print('[SoundPlayer] Error loading audio URL: $e');
      
      // Queue if URL loading fails
      final queueService = _ref.read(requestQueueServiceProvider);
      await queueService.queueRequest(
        resourceType: 'audio',
        resourceUrl: directUrl,
        request: () => setAudio(sound, loadToken),
      );
      
      Fluttertoast.showToast(
        msg: "Failed to load audio. Retrying...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      tempPlayer.dispose();
      return;
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

    // Before updating state, check token
    if (loadToken != _loadToken) return;

    state = state.copyWith(
      sound: sound,
      totalDuration: totalPlaylistDuration ?? Duration.zero,
      currentTime: Duration.zero,
      showPlayer: true,
      isPlaying: false,
      timerDuration: currentTimerDuration,
      isLiked: isFavorite(sound),
    );

    play();
    audioHandler.fadeIn(fadeInSeconds);
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

  void like() async {
    if (state.sound == null) return;
    final isFav = _favorites.any((s) => s.url == state.sound!.url);
    if (isFav) {
      _favorites.removeWhere((s) => s.url == state.sound!.url);
    } else {
      _favorites.add(state.sound!);
    }
    await _saveFavorites();
    state = state.copyWith(isLiked: !isFav);
    Fluttertoast.showToast(
      msg: state.isLiked ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void collapse() {
    state = state.copyWith(showPlayer: false);
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
        audioHandler.fadeOut(fadeOutSeconds);
        if (state.isPlaying) {
          pause();
          audioHandler.player.seek(Duration.zero);
        }
      }
    });
  }

  String googleDriveToDirect(String url) {
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
  
  // Hàm tạo đường dẫn Firebase Storage từ soundId
  String getFirebaseStoragePath(int soundId) {
    return 'sounds/$soundId.wav';
  }

  void showPlayer({SoundModel? sound}) async {
    print("Firebase Storage Path: ${sound != null ? getFirebaseStoragePath(sound.soundId) : 'null'}");
    _loadToken++; // Increment load token to track latest request
    final currentToken = _loadToken;
    final sw = Stopwatch()..start();
    // Prevent starting the same audio if already playing
    if (state.sound != null && sound != null && state.sound?.url == sound.url && state.isPlaying) {
      Fluttertoast.showToast(msg: "This audio is already playing.");
      return;
    }
    if (state.sound == null && sound != null) {
      state = state.copyWith(showPlayer: true, isLoading: true, sound: sound);
      await setAudio(sound, currentToken);
      state = state.copyWith(isLoading: false);
      play();
    } else if (state.sound == null && sound == null) {
      print("showPlayer called with no sound and no sound loaded.");
      return;
    } else if (state.sound != null && sound != null && state.sound != sound) {
      state = state.copyWith(showPlayer: true, isLoading: true, sound: sound);
      print("Loading new sound: \\${sound.title}");
      await setAudio(sound,currentToken);
      state = state.copyWith(isLoading: false);
      // Only update isLoading if this is the latest request
      if (currentToken == _loadToken) {
        state = state.copyWith(isLoading: false);
        play();
      }
    } else {
      state = state.copyWith(showPlayer: true);
      play();
    }
    print('⏱ setUrl took: \\${sw.elapsedMilliseconds} ms');
  }
  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _stopTimer?.cancel();
    _timerListenerDispose?.call();
    _connectivityListenerDispose?.call();
    audioHandler.player.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = prefs.getStringList(AppStrings.favoritesKey) ?? [];
    _favorites = favJson.map((e) => SoundModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = _favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(AppStrings.favoritesKey, favJson);
  }

  bool isFavorite(SoundModel sound) {
    return _favorites.any((s) => s.url == sound.url);
  }

  // Recents logic
  Future<void> _addToRecents(SoundModel sound) async {
    final prefs = await SharedPreferences.getInstance();
    final recentsJson = prefs.getStringList(AppStrings.recentsKey) ?? [];
    List<SoundModel> recents = recentsJson.map((e) => SoundModel.fromJson(jsonDecode(e))).toList();
    // Remove if already exists
    recents.removeWhere((s) => s.url == sound.url);
    // Insert at start
    recents.insert(0, sound);
    // Limit to 20
    if (recents.length > 20) {
      recents = recents.sublist(0, 20);
    }
    final newJson = recents.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(AppStrings.recentsKey, newJson);
  }

  Future<List<SoundModel>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final recentsJson = prefs.getStringList(AppStrings.recentsKey) ?? [];
    return recentsJson.map((e) => SoundModel.fromJson(jsonDecode(e))).toList();
  }


}