import 'package:flutter/material.dart';
import 'package:mytune/features/navigator/widgets/dark_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';
import '../../sound_player/views/sound_player_ui.dart';
import '../viewmodels/recording_view_model.dart';
import 'dart:async';

class RecordingView extends ConsumerStatefulWidget {
  const RecordingView({super.key});

  @override
  ConsumerState<RecordingView> createState() => _RecordingViewState();
}

class _RecordingViewState extends ConsumerState<RecordingView> {
  bool isScanning = false;
  int secondsLeft = 5;
  List<double> scanFrequencies = [];
  Timer? scanTimer;

  void startScan() async {
    setState(() {
      isScanning = true;
      secondsLeft = 5;
      scanFrequencies = [];
    });
    
    final notifier = ref.read(recordingViewModelProvider.notifier);
    final success = await notifier.startScan();
    
    if (!success && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Microphone permission is required to record.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() { isScanning = false; });
      return;
    }
    
    scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsLeft--;
      });
      if (secondsLeft <= 0) {
        timer.cancel();
        finishScan();
      }
    });
  }

  Future<void> cancelScan() async {
    print('View: cancelScan called');
    scanTimer?.cancel();
    await ref.read(recordingViewModelProvider.notifier).cancelScan();
    if (mounted) {
      setState(() {
        isScanning = false;
        scanFrequencies = [];
        secondsLeft = 5;
      });
    }
    print('View: cancelScan completed, isScanning: $isScanning');
  }

  void finishScan() async {
    // Stop recording
    final notifier = ref.read(recordingViewModelProvider.notifier);
    final state = ref.read(recordingViewModelProvider);
    if (scanFrequencies.isNotEmpty) {
      double avgFrequency = scanFrequencies.reduce((a, b) => a + b) / scanFrequencies.length;
      notifier.setAvgFrequency(avgFrequency);
    } else {
      notifier.setAvgFrequency(0);
    }
    if (state.value != null && state.value!.isRecording) {
      await notifier.handleRecordButtonTap();
    }
    // Calculate average

    setState(() {
      isScanning = false;
    });
    print('View: finishScan, selectedScene after update: ${ref.read(recordingViewModelProvider).value?.selectedScene}');
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.61;
    // Listen to frequency updates while scanning
    if (isScanning && recordingState.value != null && recordingState.value!.frequencies.isNotEmpty) {
      final lastFreq = recordingState.value!.frequencies.last.toDouble();
      if (scanFrequencies.isEmpty || scanFrequencies.last != lastFreq) {
        scanFrequencies.add(lastFreq);
      }
    }
    print('hieuttcheck: isScanning: $isScanning, avgFrequency: ${recordingState.value?.avgFrequency}, selectedScene: ${recordingState.value?.selectedScene}');

    // Conditional rendering based on scanning state
    if (isScanning) {
      // Original layout while scanning or before scan result
      return DarkScaffold(
        title: 'Environment Scan',
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF141318),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScanButton(
                  isScanning: isScanning,
                  secondsLeft: secondsLeft,
                  avgFrequency: recordingState.value?.avgFrequency,
                  buttonSize: buttonSize,
                  onTap: isScanning ? null : startScan,
                ),
                if (isScanning) ...[
                  const SizedBox(height: 16.0),
                  _CancelButton(onTap: cancelScan),
                ],
              ],
            ),
          ),
        ),
      );
    } else {
      // Layout when not scanning - show results if available, otherwise show initial state
      if (recordingState.value?.avgFrequency != null) {
        // Layout after scanning is complete and avgFrequency is available
        return (ref.watch(soundPlayerProvider).showPlayer)?
      SoundPlayerUI(
        currentTime: ref.watch(soundPlayerProvider).currentTime,
        isPlaying: ref.watch(soundPlayerProvider).isPlaying,
        onCollapse: () => ref.read(soundPlayerProvider.notifier).collapse(),
        onLike: () => ref.read(soundPlayerProvider.notifier).like(),
        onPlayPause: () => ref.read(soundPlayerProvider.notifier).togglePlayPause(),
        onQueue: () {},
        sound: ref.watch(soundPlayerProvider).sound,
        totalDuration: ref.watch(soundPlayerProvider).timerDuration,
      ):DarkScaffold(
        title: 'Environment Scan',
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF141318),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: _ScanButton(
                    isScanning: isScanning,
                    secondsLeft: secondsLeft,
                    avgFrequency: recordingState.value?.avgFrequency,
                    buttonSize: buttonSize,
                    onTap: isScanning ? null : startScan, // Keep tap to rescan?
                  ),
                ),
                const SizedBox(height: 48.0),
                Text(
                  'Your Sonic Reading',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                _SonicReadingCard(avgFrequency: recordingState.value?.avgFrequency??0, frequencyDescription: recordingState.value?.frequencyDescription),
                const SizedBox(height: 48.0),
                recordingState.value?.selectedScene == null
                    ? Column(
                        children: [
                          Text(
                            'Choose your scene',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          _ChooseYourSceneGrid(onSceneSelected: (scene) {
                            ref.read(recordingViewModelProvider.notifier).updateSelectedScene(scene);
                            setState(() {});
                          }),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            'Recommended Tune',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          _RecommendedTunesList(),
                          const SizedBox(height: 48.0),
                          _ScanAgainButton(onTap: () {
                            startScan();
                          }),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
      } else {
        // Layout when avgFrequency is null (after cancel or initial state)
        return DarkScaffold(
          title: 'Environment Scan',
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF141318),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScanButton(
                    isScanning: isScanning,
                    secondsLeft: secondsLeft,
                    avgFrequency: recordingState.value?.avgFrequency,
                    buttonSize: buttonSize,
                    onTap: isScanning ? null : startScan,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}

class _ScanButton extends StatelessWidget {
  final bool isScanning;
  final int secondsLeft;
  final double? avgFrequency;
  final double buttonSize;
  final VoidCallback? onTap;
  const _ScanButton({
    required this.isScanning,
    required this.secondsLeft,
    required this.avgFrequency,
    required this.buttonSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print('_ScanButton: isScanning: $isScanning, avgFrequency: $avgFrequency');
    Color? glowColor;
    if (!isScanning && avgFrequency != null) {
      if (avgFrequency! > 6000) {
        glowColor = Colors.redAccent;
      } else if (avgFrequency! > 1000) {
        glowColor = Colors.yellowAccent;
      } else {
        glowColor = Colors.greenAccent;
      }
    }
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glowColor != null)
            Container(
              width: buttonSize , // slightly larger for glow
              height: buttonSize ,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.55),
                    blurRadius: buttonSize * 0.32,
                    // spreadRadius: buttonSize * 0.0001,
                  ),
                  BoxShadow(
                    color: glowColor.withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: Colors.white.withOpacity(0.08),
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF2E2B3C),
                  Color(0xFF131219),
                ],
              ),
              border: Border.all(
                color: const Color(0x1AFFFFFF),
                width: 1.71,
              ),
            ),
            child: Center(
              child: isScanning
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Scanning...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$secondsLeft seconds left',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  : avgFrequency != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${avgFrequency!.round()} Hz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonSize * 0.22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: buttonSize * 0.28,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SonicReadingCard extends StatelessWidget {
  final double avgFrequency;
  final String? frequencyDescription;

  const _SonicReadingCard({required this.avgFrequency, this.frequencyDescription});

  String _getReadingText(double frequency) {
    if (frequency <= 500) {
      return 'Detected a low frequency hum around ${frequency.round()} Hz — this is common with HVAC systems or large machinery. Masking with brown noise can help improve focus.';
    } else if (frequency <= 1000) {
      return 'Detected a hum around ${frequency.round()} Hz — that\'s common with ACs or electronics. Masking with pink or brown noise can help balance it out.';
    } else if (frequency <= 6000) {
      return 'Detected a frequency spike around ${frequency.round()} Hz — possibly from lighting or monitors. Masking with white or pink noise might be beneficial.';
    } else {
      return 'Detected a high frequency sound around ${frequency.round()} Hz — could be from electronics or environmental factors. White noise is often effective for masking higher frequencies.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.84;
    // final screenHeight = MediaQuery.of(context).size.height;
    // final cardHeight = screenHeight * 0.16;

    Color borderColor = Colors.transparent;
    if (avgFrequency > 1000 && avgFrequency <= 6000) {
      borderColor = Colors.yellow.withOpacity(0.6);
    }

    return Center(
      child: Container(
        width: cardWidth,
        // height: cardHeight,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A), // Dark background color
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            frequencyDescription ?? _getReadingText(avgFrequency),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ChooseYourSceneGrid extends StatelessWidget {
  final Function(String) onSceneSelected;

  _ChooseYourSceneGrid({required this.onSceneSelected});

  final List<Map<String, dynamic>> scenes = [
    {'name': 'Sleep', 'icon': Icons.nights_stay},
    {'name': 'Relax', 'icon': Icons.sentiment_satisfied_alt},
    {'name': 'Stress Relief', 'icon': Icons.sentiment_dissatisfied},
    {'name': 'Deep Work', 'icon': Icons.work},
    {'name': 'Energy Boost', 'icon': Icons.bolt},
    {'name': 'Meditate', 'icon': Icons.self_improvement},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.85,
      ),
      itemCount: scenes.length,
      itemBuilder: (context, index) {
        final scene = scenes[index];
        return GestureDetector(
          onTap: () => onSceneSelected(scene['name']),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: Icon(
                  scene['icon'],
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                scene['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendedTunesList extends ConsumerWidget {
  // Placeholder data - replace with actual SoundModel list

  const _RecommendedTunesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final recommendedTunes = ref.watch(recordingViewModelProvider).value?.recommendedTunes ?? [];
    return SizedBox(
      height: 158.0, // Height for horizontal list items
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedTunes.length,
        itemBuilder: (context, index) {
          final tune = recommendedTunes[index];
          return GestureDetector(
            onTap: () => ref.read(soundPlayerProvider.notifier).showPlayer(sound:tune),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0), // Spacing between items
              child: Container(
                width: 158.0,
                height: 158.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: NetworkImage(ref.read(soundPlayerProvider.notifier).googleDriveToDirect(tune.url_avatar)), // Use AssetImage for local assets
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Optional overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12.0,
                      bottom: 12.0,
                      child: Text(
                        tune.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanAgainButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanAgainButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E2B3C), // Background color
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
          side: const BorderSide(color: Color(0x1AFFFFFF), width: 1.71),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.refresh, size: 24),
          SizedBox(width: 8.0),
          Text(
            'Scan Again',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E2B3C),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Color(0x33FF6B6B), width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.close, size: 20),
          SizedBox(width: 8.0),
          Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}