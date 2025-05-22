import 'package:flutter_riverpod/flutter_riverpod.dart';


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