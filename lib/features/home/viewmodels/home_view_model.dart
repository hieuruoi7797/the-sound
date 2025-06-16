import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/data/realtime_database_service.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeState {
  final List<SoundModel> topPicks;
  final bool isLoading;
  final String? error;

  HomeState({
    this.topPicks = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<SoundModel>? topPicks,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      topPicks: topPicks ?? this.topPicks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<HomeState> {
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  StreamSubscription<DatabaseEvent>? _topPicksSub;

  HomeViewModel() : super(HomeState()) {
    fetchSoundData();
  }

  void fetchSoundData() {
    print('[HomeViewModel] Fetching sound data from root...');
    state = state.copyWith(isLoading: true, error: null);
    _topPicksSub?.cancel();
    _topPicksSub = _dbService.readData('').listen((event) {
      try {
        final data = event.snapshot.value;
        print('[HomeViewModel] Data snapshot received:');
        print(data);
        if (data is Map) {
          final systemSounds = SystemSoundsModel.fromJson(Map<String, dynamic>.from(data));
          print('[HomeViewModel] Parsed ${systemSounds.sounds.length} sounds from SystemSoundsModel');
          state = state.copyWith(topPicks: systemSounds.sounds, isLoading: false, error: null);
        } else {
          print('[HomeViewModel] No valid data found.');
          state = state.copyWith(topPicks: [], isLoading: false, error: null);
        }
        print('[HomeViewModel] State updated: topPicks=${state.topPicks.length}, isLoading=${state.isLoading}, error=${state.error}');
      } catch (e) {
        print('[HomeViewModel] Error parsing data: $e');
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }, onError: (e) {
      print('[HomeViewModel] Error fetching data: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    });
  }

  @override
  void dispose() {
    _topPicksSub?.cancel();
    super.dispose();
  }
}

class SystemSoundsModel {
  final List<SoundModel> sounds;

  SystemSoundsModel({required this.sounds});

  factory SystemSoundsModel.fromJson(Map<String, dynamic> json) {
    final dynamic raw = json['system_sounds'];
    List<SoundModel> sounds = [];
    if (raw is List) {
      sounds = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => SoundModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (raw is Map) {
      sounds = (raw as Map).values
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => SoundModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return SystemSoundsModel(sounds: sounds);
  }

  Map<String, dynamic> toJson() {
    return {
      'system_sounds': sounds.map((e) => e.toJson()).toList(),
    };
  }
} 