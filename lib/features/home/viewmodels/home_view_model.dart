import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/data/realtime_database_service.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeState {
  final List<SoundModel> allSounds;
  final List<SoundModel> topPicks;
  final List<SoundModel> topPicksAll;
  final bool isLoading;
  final String? error;

  HomeState({
    this.allSounds = const [],
    this.isLoading = false,
    this.topPicks = const [],
    this.topPicksAll = const [],
    this.error,
  });

  HomeState copyWith({
    List<SoundModel>? allSounds,
    bool? isLoading,
    List<SoundModel>? topPicks,
    List<SoundModel>? topPicksAll,
    String? error,
  }) {
    return HomeState(
      allSounds: allSounds ?? this.allSounds,
      isLoading: isLoading ?? this.isLoading,
      topPicks: topPicks ?? this.topPicks,
      topPicksAll: topPicksAll ?? this.topPicksAll,
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

  HomeViewModel() : super(HomeState()) {}

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
          state = state.copyWith(allSounds: systemSounds.sounds, isLoading: false, error: null);
          makeTopPicks();
        } else {
          print('[HomeViewModel] No valid data found.');
          state = state.copyWith(allSounds: [], isLoading: false, error: null);
          makeTopPicks();
        }
        print('[HomeViewModel] State updated: topPicks=${state.allSounds.length}, isLoading=${state.isLoading}, error=${state.error}');
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

  // Add getters for each mode's sound list
  List<SoundModel> get sleepSounds => state.allSounds.where((s) => s.tags.contains(202)).toList();
  List<SoundModel> get relaxSounds => state.allSounds.where((s) => s.tags.contains(303)).toList();
  List<SoundModel> get meditateSounds => state.allSounds.where((s) => s.tags.contains(404)).toList();
  List<SoundModel> get deepworkSounds => state.allSounds.where((s) => s.tags.contains(505)).toList();
  List<SoundModel> get energyBoostSounds => state.allSounds.where((s) => s.tags.contains(606)).toList();
  List<SoundModel> get stressReliefSounds => state.allSounds.where((s) => s.tags.contains(707)).toList();
  List<SoundModel> get healingBodySounds => state.allSounds.where((s) => s.tags.contains(808)).toList();
  List<SoundModel> get topPicksAll => state.topPicksAll;

  void makeTopPicks() {
    // Shuffle and pick 5 random sounds
    final randomSounds = List<SoundModel>.from(state.allSounds)..shuffle();
    final topPicksAll = randomSounds.take(50).toList();
    final topPicks = topPicksAll.take(5).toList();
    state = state.copyWith(
      topPicks: topPicks,
      topPicksAll: topPicksAll,
    );
    print('[HomeViewModel] Top picks made: ${topPicks.length} from ${topPicksAll.length} total sounds');
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