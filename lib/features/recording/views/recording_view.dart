import 'package:flutter/material.dart';
import 'package:flutter_mvvm_app/features/navigator/widgets/dark_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recording_view_model.dart';
import 'dart:math';

class RecordingView extends ConsumerWidget {
  const RecordingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingViewModelProvider);
    final recordingNotifier = ref.read(recordingViewModelProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.61;

    return DarkScaffold(
      title: 'Environment Scan',
      body: recordingState.when(
        data: (state) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF141318),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  
                  // Main Content
                  Center(
                    child: _AnimatedGlowRecordButton(
                      isRecording: state.isRecording,
                      frequency: state.frequencies.isNotEmpty ? state.frequencies.last : 0,
                      buttonSize: buttonSize,
                      onTap: () async {
                        final success = await recordingNotifier.handleRecordButtonTap();
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
                        }
                      },
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _AnimatedGlowRecordButton extends StatefulWidget {
  final bool isRecording;
  final double frequency;
  final double buttonSize;
  final VoidCallback onTap;
  const _AnimatedGlowRecordButton({
    required this.isRecording,
    required this.frequency,
    required this.buttonSize,
    required this.onTap,
  });

  @override
  State<_AnimatedGlowRecordButton> createState() => _AnimatedGlowRecordButtonState();
}

class _AnimatedGlowRecordButtonState extends State<_AnimatedGlowRecordButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _glowAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.isRecording) {
      _controller.value = _frequencyToGlow(widget.frequency);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedGlowRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording) {
      final target = _frequencyToGlow(widget.frequency);
      _controller.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _controller.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  double _frequencyToGlow(double freq) {
    // Map frequency (e.g., 0-2000 Hz) to 0.2-1.0 intensity
    final minF = 100.0;
    final maxF = 2000.0;
    final norm = ((freq - minF) / (maxF - minF)).clamp(0.0, 1.0);
    return 0.2 + 0.8 * norm;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseGlowSize = max(widget.buttonSize + 80, 240.0 + 80); // ensure glow is outside 240x240
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowSize = baseGlowSize + 40 * _glowAnimation.value; // animate size
        final glowOpacity = 0.5 + 0.5 * _glowAnimation.value; // animate opacity
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isRecording)
              Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(glowOpacity),
                      blurRadius: 9 + 9 * _glowAnimation.value,
                      spreadRadius: 3 + 3 * _glowAnimation.value,
                      offset: Offset.zero,
                      blurStyle: BlurStyle.outer
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.buttonSize,
                height: widget.buttonSize,
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
                  child: widget.isRecording
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.frequency.toStringAsFixed(2) + ' Hz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.buttonSize * 0.22,
                                fontWeight: FontWeight.bold,
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
                              size: widget.buttonSize * 0.28,
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
            ),
          ],
        );
      },
    );
  }
} 