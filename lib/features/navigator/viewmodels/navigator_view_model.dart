import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';


// Provider for the current tab index
final navigatorViewModelProvider = StateNotifierProvider<NavigatorViewModel, int>((ref) {
  return NavigatorViewModel();
});

class NavigatorViewModel extends StateNotifier<int> {
  NavigatorViewModel() : super(0); // Default to first tab (Home)
  
  void setTab(int index, WidgetRef ref) {
    ref.read(soundPlayerProvider.notifier).collapse();
    state = index;
  }
} 