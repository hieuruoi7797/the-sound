import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording_service.dart';

final recordingServiceProvider = Provider((ref) => RecordingService());

final recordingViewModelProvider =
    StateNotifierProvider<RecordingViewModel, AsyncValue<RecordingState>>((ref) {
  final service = ref.watch(recordingServiceProvider);
  return RecordingViewModel(service);
});

class RecordingState {
  final bool isRecording;
  final List<double> frequencies;
  final bool hasPermission;

  RecordingState({
    this.isRecording = false,
    this.frequencies = const [],
    this.hasPermission = false,
  });

  RecordingState copyWith({
    bool? isRecording,
    List<double>? frequencies,
    bool? hasPermission,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      frequencies: frequencies ?? this.frequencies,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class RecordingViewModel extends StateNotifier<AsyncValue<RecordingState>> {
  final RecordingService _service;
  StreamSubscription<double>? _frequencySubscription;

  RecordingViewModel(this._service)
      : super(AsyncValue.data(RecordingState())) {
    _checkPermission();
  }

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
      } else {
        await _service.stopRecording();
        await _frequencySubscription?.cancel();
      }

      state = AsyncValue.data(currentState.copyWith(
        isRecording: !currentState.isRecording,
        frequencies: !currentState.isRecording ? [] : currentState.frequencies,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _startListeningFrequency() {
    _frequencySubscription = _service.frequencyStream.listen((frequency) {
      if (state.value == null) return;
      
      final currentState = state.value!;
      final newFrequencies = List<double>.from(currentState.frequencies)
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

  @override
  void dispose() {
    _frequencySubscription?.cancel();
    super.dispose();
  }
} 