import 'package:flutter/material.dart';
import 'package:mytune/features/navigator/widgets/dark_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  double? avgFrequency;

  void startScan() async {
    setState(() {
      isScanning = true;
      secondsLeft = 5;
      scanFrequencies = [];
      avgFrequency = null;
    });
    // Start recording if not already
    final notifier = ref.read(recordingViewModelProvider.notifier);
    final state = ref.read(recordingViewModelProvider);
    if (state.value == null || !state.value!.isRecording) {
      final success = await notifier.handleRecordButtonTap();
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

  void finishScan() async {
    // Stop recording
    final notifier = ref.read(recordingViewModelProvider.notifier);
    final state = ref.read(recordingViewModelProvider);
    if (state.value != null && state.value!.isRecording) {
      await notifier.handleRecordButtonTap();
    }
    // Calculate average
    if (scanFrequencies.isNotEmpty) {
      avgFrequency = scanFrequencies.reduce((a, b) => a + b) / scanFrequencies.length;
    } else {
      avgFrequency = 0;
    }
    setState(() {
      isScanning = false;
    });
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
      final lastFreq = recordingState.value!.frequencies.last;
      if (scanFrequencies.isEmpty || scanFrequencies.last != lastFreq) {
        scanFrequencies.add(lastFreq);
      }
    }
    return DarkScaffold(
      title: 'Environment Scan',
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF141318),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _ScanButton(
                  isScanning: isScanning,
                  secondsLeft: secondsLeft,
                  avgFrequency: avgFrequency,
                  buttonSize: buttonSize,
                  onTap: isScanning ? null : startScan,
                ),
              ),
              // Home Indicator
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
          );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF595571),
              Color(0xFF1F1E28),
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
    );
  }
} 