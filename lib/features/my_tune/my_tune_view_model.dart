import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyTuneViewModel extends Notifier<void> {
  @override
  void build() {
    // Initial state setup if needed
  }
}

final myTuneViewModelProvider = NotifierProvider<MyTuneViewModel, void>(MyTuneViewModel.new); 