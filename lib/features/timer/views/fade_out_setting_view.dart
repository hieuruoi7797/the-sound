import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/timer/viewmodels/fade_out_setting_view_model.dart';

class FadeOutSettingView extends ConsumerWidget {
  const FadeOutSettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDuration = ref.watch(fadeOutSettingViewModelProvider);
    final viewModel = ref.read(fadeOutSettingViewModelProvider.notifier);

    // Define the list of fade-out duration options
    final List<Duration> fadeOutOptions = [
      Duration(seconds: 0),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 5),
      Duration(minutes: 10),
    ];

    // Helper function to format duration for display
    String formatDuration(Duration duration) {
      if (duration.inMinutes > 0) {
        return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
      } else {
        return '${duration.inSeconds} second${duration.inSeconds > 1 || duration.inSeconds == 0 ? 's' : ''}';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Fade Out'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: ListView.builder(
        itemCount: fadeOutOptions.length,
        itemBuilder: (context, index) {
          final duration = fadeOutOptions[index];
          final isSelected = selectedDuration == duration;
          return ListTile(
            title: Text(formatDuration(duration)),
            trailing: isSelected ? Icon(Icons.check) : null,
            onTap: () {
              viewModel.setFadeOutDuration(duration);
              // Navigator.pop(context); // Navigate back after selecting - decided to not pop automatically
            },
          );
        },
      ),
    );
  }
} 