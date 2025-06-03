import 'package:flutter_riverpod/flutter_riverpod.dart';

final fadeOutSettingViewModelProvider = StateNotifierProvider<FadeOutSettingViewModel, Duration>((ref) {
  // Default fade-out duration is 5 seconds
  return FadeOutSettingViewModel(const Duration(seconds: 5));
});

class FadeOutSettingViewModel extends StateNotifier<Duration> {
  FadeOutSettingViewModel(Duration initialDuration) : super(initialDuration);

  void setFadeOutDuration(Duration duration) {
    state = duration;
  }
} 