import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final int fadeInSeconds;
  final int fadeOutSeconds;
  const SettingsState({
    this.fadeInSeconds = 5,
    this.fadeOutSeconds = 5,
  });

  SettingsState copyWith({int? fadeInSeconds, int? fadeOutSeconds}) {
    return SettingsState(
      fadeInSeconds: fadeInSeconds ?? this.fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fadeIn = prefs.getInt('fadeInSeconds') ?? 5;
    final fadeOut = prefs.getInt('fadeOutSeconds') ?? 5;
    state = state.copyWith(fadeInSeconds: fadeIn, fadeOutSeconds: fadeOut);
  }

  Future<void> setFadeInSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fadeInSeconds', seconds);
    state = state.copyWith(fadeInSeconds: seconds);
  }

  Future<void> setFadeOutSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fadeOutSeconds', seconds);
    state = state.copyWith(fadeOutSeconds: seconds);
  }
}

final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>(
  (ref) => SettingsViewModel(),
); 