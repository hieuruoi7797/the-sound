import 'package:flutter/material.dart';
import '../models/sound_model.dart';

class SoundPlayerUI extends StatelessWidget {
  final SoundModel? sound;
  final Duration currentTime;
  final bool isPlaying;
  final VoidCallback onCollapse;
  final VoidCallback onLike;
  final VoidCallback onPlayPause;
  final VoidCallback onTimer;
  final VoidCallback onQueue;
  final Duration totalDuration;
  const SoundPlayerUI({
    super.key,
    this.sound,
    required this.currentTime,
    required this.isPlaying,
    required this.onCollapse,
    required this.onLike,
    required this.onPlayPause,
    required this.onTimer,
    required this.onQueue,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C576A),
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Collapse button
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: onCollapse,
                      ),
                    ),
                    // Like button
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: onLike,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Audio name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    sound?.audioName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Description
                if (sound?.description.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      sound?.description ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Circular avatar
                CircleAvatar(
                  radius: 120,
                  backgroundImage: NetworkImage(sound?.imageUrl ?? ''),
                ),
                const SizedBox(height: 40),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Slider(
                        value: currentTime.inSeconds.toDouble(),
                        min: 0,
                        max: totalDuration.inSeconds.toDouble(),
                        onChanged: (_) {}, // For display only
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(currentTime), style: const TextStyle(color: Colors.white70)),
                          Text(_formatDuration(totalDuration ?? Duration.zero), style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Controller row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(icon: Icons.timer, onTap: onTimer),
                    _circleButton(icon: isPlaying ? Icons.pause : Icons.play_arrow, onTap: onPlayPause),
                    _circleButton(icon: Icons.queue_music, onTap: onQueue),
                  ],
                ),
                const Spacer(),
                // Home indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
} 