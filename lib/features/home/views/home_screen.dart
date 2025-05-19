import 'package:flutter/material.dart';
import '../widgets/environment_scan_banner.dart';
import '../widgets/noise_type_card.dart';
import '../widgets/daily_mode_card.dart';
import '../widgets/top_pick_card.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141318),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigate to Profile/Settings
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Environment Scan Banner
                  EnvironmentScanBanner(
                  ),

                  // Colored Noise List
                  const Text(
                    'Colored Noise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        NoiseTypeCard(
                          title: 'White',
                          icon: Icons.grain,
                          color: Color(0xFF7B61FF),
                        ),
                        NoiseTypeCard(
                          title: 'Pink',
                          icon: Icons.grain,
                          color: Color(0xFFFF61A3),
                        ),
                        NoiseTypeCard(
                          title: 'Brown',
                          icon: Icons.grain,
                          color: Color(0xFFA361FF),
                        ),
                        NoiseTypeCard(
                          title: 'Green',
                          icon: Icons.grain,
                          color: Color(0xFF61FFA3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daily Modes
                  const Text(
                    'Daily Modes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        DailyModeCard(
                          title: 'Easy Sleep',
                          description: 'Calm your mind',
                          icon: Icons.nightlight_round,
                          color: Color(0xFF7B61FF),
                        ),
                        DailyModeCard(
                          title: 'Deep Focus',
                          description: 'Boost productivity',
                          icon: Icons.psychology,
                          color: Color(0xFF61A3FF),
                        ),
                        DailyModeCard(
                          title: 'Relaxation',
                          description: 'Reduce stress',
                          icon: Icons.spa,
                          color: Color(0xFFFF6161),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Picks
                  const Text(
                    'Top Picks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.14,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        TopPickCard(
                          title: 'Ocean Waves',
                          artist: 'Nature Sounds',
                          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                          playCount: 1250000,
                        ),
                        TopPickCard(
                          title: 'Rain Forest',
                          artist: 'Ambient Nature',
                          imageUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969',
                          playCount: 890000,
                        ),
                        TopPickCard(
                          title: 'White Noise',
                          artist: 'Sleep Sounds',
                          imageUrl: 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484',
                          playCount: 750000,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Space for mini player
                ],
              ),
            ),
            // Mini Player
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(
                title: 'Ocean Waves',
                artist: 'Nature Sounds',
                imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                isPlaying: true,
                onPlayPause: () {
                  // Handle play/pause
                },
                onTap: () {
                  // Navigate to full player
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}