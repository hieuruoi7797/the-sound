import 'dart:async';
import 'dart:math';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/viewmodels/home_view_model.dart';
import '../../sound_player/models/sound_model.dart';
import '../services/recording_service.dart';
import '../../../data/realtime_database_service.dart';

final recordingServiceProvider = Provider((ref) => RecordingService(ref.watch(realtimeDatabaseServiceProvider)));

final realtimeDatabaseServiceProvider = Provider((ref) => RealtimeDatabaseService());

final recordingViewModelProvider =
    StateNotifierProvider<RecordingViewModel, AsyncValue<RecordingState>>((ref) {
  final service = ref.watch(recordingServiceProvider);
  return RecordingViewModel(service, ref);
});

class RecordingState {
  final bool isRecording;
  final List<int> frequencies;
  final bool hasPermission;
  final String? frequencyDescription;
  final String? selectedScene;
  final List<SoundModel>? recommendedTunes;
  final double? avgFrequency;

  RecordingState({
    this.isRecording = false,
    this.frequencies = const [],
    this.hasPermission = false,
    this.frequencyDescription,
    this.selectedScene,
    this.recommendedTunes = const [],
    this.avgFrequency,
  });

  RecordingState copyWith({
    bool? isRecording,
    List<int>? frequencies,
    bool? hasPermission,
    String? frequencyDescription,
    String? selectedScene,
    List<SoundModel>? recommendedTunes,
    double? avgFrequency,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      frequencies: frequencies ?? this.frequencies,
      hasPermission: hasPermission ?? this.hasPermission,
      frequencyDescription: frequencyDescription ?? this.frequencyDescription,
      selectedScene: selectedScene,
      recommendedTunes: recommendedTunes,
      avgFrequency: avgFrequency ?? this.avgFrequency,
    );
  }
}

class RecordingViewModel extends StateNotifier<AsyncValue<RecordingState>> {
  final RecordingService _service;
  StreamSubscription<int>? _frequencySubscription;

  RecordingViewModel(this._service, this.ref)
      : super(AsyncValue.data(RecordingState())) {
    _checkPermission();
  }
  final Ref ref;


  Future<void> _checkPermission() async {
    try {
      final hasPermission = await _service.checkPermissionStatus();
      state = AsyncValue.data(RecordingState(hasPermission: hasPermission));
      if (!hasPermission) {
        _requestPermission();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _requestPermission() async {
    try {
      final hasPermission = await _service.requestPermission();
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(
          hasPermission: hasPermission,
        ));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> retryPermission() async {
    await _requestPermission();
  }

  Future<void> toggleRecording() async {
    if (state.value == null) return;

    try {
      final currentState = state.value!;
      if (!currentState.isRecording) {
        await _service.startRecording();
        _startListeningFrequency();
        state = AsyncValue.data(currentState.copyWith(
          isRecording: true,
          frequencies: [],
          frequencyDescription: null,
          selectedScene: null,
        ));
        print('ViewModel: Scan started, selectedScene: ${currentState.selectedScene}');
        return;
      } else {
        await _service.stopRecording();
        await _frequencySubscription?.cancel();

        // double? avgFrequency;
        String? description;

        if (currentState.frequencies.isNotEmpty) {
          await updateFrequenciesRange(state.value?.avgFrequency?.toInt()??0);
          // avgFrequency = currentState.frequencies.reduce((a, b) => a + b) / currentState.frequencies.length;
          description = await _service.getFrequencyDescription(state.value?.avgFrequency ?? 0.0);
        }

        state = AsyncValue.data(currentState.copyWith(
          isRecording: false,
          frequencyDescription: description,
          selectedScene: null,
        ));
        print('ViewModel: Scan stopped, selectedScene: ${currentState.selectedScene}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _startListeningFrequency() {
    _frequencySubscription = _service.frequencyStream.listen((frequency) {
      if (state.value == null) return;
      
      final currentState = state.value!;
      final newFrequencies = List<int>.from(currentState.frequencies)
        ..add(frequency);
      if (newFrequencies.length > 50) newFrequencies.removeAt(0);
      
      state = AsyncValue.data(currentState.copyWith(
        frequencies: newFrequencies,
      ));
    });
  }

  Future<bool> requestPermissionWithResult() async {
    try {
      final hasPermission = await _service.checkPermissionStatus();
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(
          hasPermission: hasPermission,
        ));
      }
      return hasPermission;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Handles the logic for the record button tap.
  /// Returns true if permission is granted and recording is toggled, false if permission is denied.
  Future<bool> handleRecordButtonTap() async {
    if (state.value == null) return false;
    if (!state.value!.hasPermission) {
      final hasPermission = await requestPermissionWithResult();
      if (!hasPermission) {
        return false;
      }
    }
    await toggleRecording();
    return true;
  }
  Future<void> updateFrequenciesRange(int frequency) async {
    List<int> frequenciesRange = await _service.getFrequenciesRage(frequency);
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(frequencies: frequenciesRange));
  }

  void updateSelectedScene(String? scene) {
    if (state.value == null) return;
    final allSounds = ref.read(homeViewModelProvider).allSounds;
    final frequencies = state.value!.frequencies;
    if (frequencies.isEmpty) return;
    // Example: use min/max frequency as range
    final minFreq = frequencies.reduce((a, b) => a < b ? a : b);
    final maxFreq = frequencies.reduce((a, b) => a > b ? a : b);

    // Filter sounds: first tag must be a number in [minFreq, maxFreq]
    final filtered = allSounds.where((sound) {
      if (sound.tags.isEmpty) return false;
      final tagValue = double.tryParse(sound.tags.first.toString());
      if (tagValue == null) return false;
      return tagValue >= minFreq && tagValue <= maxFreq;
    }).toList();

    print('Filtered sounds: ${filtered.map((s) => s.title).toList()}');

    final random = Random();
    final List<SoundModel> shuffled = List.from(filtered)..shuffle(random);
    final List<SoundModel> picked = shuffled.take(3).toList();
    print('Picked recommended tunes: $scene ${picked.map((s) => s.title).toList()}');

    state = AsyncValue.data(state.value!.copyWith(
        selectedScene: scene,
        recommendedTunes: picked,));
  }

  @override
  void dispose() {
    _frequencySubscription?.cancel();
    super.dispose();
  }

  void setAvgFrequency(double avgFrequency) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(avgFrequency: avgFrequency));
  }

  void showPlayer(SoundModel tune) {

  }
} 