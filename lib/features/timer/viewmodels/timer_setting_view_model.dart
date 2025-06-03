import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerSettingViewModelProvider = StateNotifierProvider<TimerSettingViewModel, Duration>((ref) {
  return TimerSettingViewModel();
});

class TimerSettingViewModel extends StateNotifier<Duration> {
  TimerSettingViewModel() : super(const Duration(hours: 2));

  int _selectedHours = 2;
  int _selectedMinutes = 0;

  void updateHours(int hours) {
    _selectedHours = hours;
    _updateTimerDuration();
  }

  void updateMinutes(int minutes) {
    _selectedMinutes = minutes;
    _updateTimerDuration();
  }

  void setTimerDuration(Duration duration) {
    _selectedHours = duration.inHours;
    _selectedMinutes = duration.inMinutes.remainder(60);
    state = duration;
  }

  void _updateTimerDuration() {
    state = Duration(hours: _selectedHours, minutes: _selectedMinutes);
  }

  // TODO: Add timer countdown and completion logic
} 