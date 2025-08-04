// In lib/features/timer/views/timer_setting_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/fade_out_setting_view_model.dart';
import '../viewmodels/timer_setting_view_model.dart';
import 'fade_out_setting_view.dart';

class TimerSettingView extends ConsumerStatefulWidget {
  const TimerSettingView({super.key});

  @override
  ConsumerState<TimerSettingView> createState() => _TimerSettingViewState();
}

class _TimerSettingViewState extends ConsumerState<TimerSettingView> {
  late FixedExtentScrollController _hoursScrollController;
  late FixedExtentScrollController _minutesScrollController;

  @override
  void initState() {
    final timerViewModel = ref.read(timerSettingViewModelProvider);
    _hoursScrollController =
        FixedExtentScrollController(initialItem: timerViewModel.inHours);
    _minutesScrollController = FixedExtentScrollController(
        initialItem: timerViewModel.inMinutes.remainder(60));
    super.initState();
  }

  @override
  void dispose() {
    _hoursScrollController.dispose();
    _minutesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFadeOutDuration = ref.watch(fadeOutSettingViewModelProvider);
    final timerViewModel = ref.watch(timerSettingViewModelProvider);
    final timerViewModelNotifier =
        ref.read(timerSettingViewModelProvider.notifier);

    return Container(
      height:
          MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Use scaffold background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer',
                  style: Theme.of(context).textTheme.titleLarge, // Use appropriate text style
                ),
                IconButton(
                  icon: Icon(Icons.close), // Close button
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Custom Time Picker (Replicating the image)
          SizedBox(
            height: 150, // Adjust height as needed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours picker
                SizedBox(
                  width: 80, // Adjust width
                  child: CupertinoPicker(
                    itemExtent: 40, // Height of each item
                    scrollController: _hoursScrollController, // Set initial item
                    onSelectedItemChanged: (int index) {
                      timerViewModelNotifier.updateHours(index);
                    },
                    children: List<Widget>.generate(24, (int index) {
                      return Center(child: Text(index.toString()));
                    }),
                  ),
                ),
                Text('hours', style: Theme.of(context).textTheme.titleMedium), // Use appropriate text style
                SizedBox(width: 20), // Spacing
                // Minutes picker
                SizedBox(
                  width: 80, // Adjust width
                  child: CupertinoPicker(
                    itemExtent: 40, // Height of each item
                    scrollController: _minutesScrollController, // Set initial item
                    onSelectedItemChanged: (int index) {
                      timerViewModelNotifier.updateMinutes(index);
                    },
                    children: List<Widget>.generate(60, (int index) {
                      return Center(child: Text(index.toString()));
                    }),
                  ),
                ),
                Text('min', style: Theme.of(context).textTheme.titleMedium), // Use appropriate text style
              ],
            ),
          ),
          SizedBox(height: 20),
          // Preset timer options (using the buttons from the image)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimerPresetButton(
                      context, ref, const Duration(minutes: 15), '15', 'min',
                      () {
                    _hoursScrollController.jumpToItem(0);
                    _minutesScrollController.jumpToItem(15);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(minutes: 25), '25', 'min',
                      () {
                    _hoursScrollController.jumpToItem(0);
                    _minutesScrollController.jumpToItem(25);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(minutes: 30), '30', 'min',
                      () {
                    _hoursScrollController.jumpToItem(0);
                    _minutesScrollController.jumpToItem(30);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(minutes: 45), '45', 'min',
                      () {
                    _hoursScrollController.jumpToItem(0);
                    _minutesScrollController.jumpToItem(45);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(minutes: 90), '90', 'min',
                      () {
                    _hoursScrollController.jumpToItem(1);
                    _minutesScrollController.jumpToItem(30);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(hours: 8), '8', 'hours', () {
                    _hoursScrollController.jumpToItem(8);
                    _minutesScrollController.jumpToItem(0);
                  }),
                  _buildTimerPresetButton(
                      context, ref, const Duration(hours: 12), '12', 'hours',
                      () {
                    _hoursScrollController.jumpToItem(12);
                    _minutesScrollController.jumpToItem(0);
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 30), // Spacing

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'When the timer ends',
                style: Theme.of(context).textTheme.titleMedium, // Use appropriate text style
              ),
            ),
          ),
          SizedBox(height: 10), // Spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use card color for the container
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: ListTile(
                leading: Icon(Icons.volume_down), // Replace with fade-out icon if available
                title: Text('Fade Out'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${selectedFadeOutDuration.inSeconds} seconds', style: Theme.of(context).textTheme.bodyMedium), // Display selected duration
                    Icon(Icons.chevron_right), // Arrow icon
                  ],
                ), // Arrow icon
                onTap: () {
                  // Navigate to Fade Out setting screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FadeOutSettingView()),
                  );
                },
              ),
            ),
          ),
          // Optional: Add a description below the Fade Out tile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Slowly lower the volume at the end of playback to avoid abrupt stops',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey), // Use a smaller text style with grey color
            ),
          ),
          // ... other widgets ...
        ],
      ),
    );
  }

  Widget _buildTimerPresetButton(
    BuildContext context,
    WidgetRef ref,
    Duration duration,
    String value,
    String unit,
    VoidCallback onJumpToItem,
  ) {
    final timerViewModel = ref.watch(timerSettingViewModelProvider);
    final bool isSelected = timerViewModel == duration;
    return Container(
      margin: EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: () {
          ref
              .read(timerSettingViewModelProvider.notifier)
              .setTimerDuration(duration);
          onJumpToItem();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null)),
            Text(unit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null)),
          ],
        ),
      ),
    );
  }
}
