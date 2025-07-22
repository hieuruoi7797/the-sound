import 'package:flutter/material.dart';
import 'package:mytune/core/constants/assets.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:mytune/features/sound_player/views/sound_player_ui.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';
import '../widgets/environment_scan_banner.dart';
import '../widgets/noise_type_card.dart';
import '../widgets/daily_mode_card.dart';
import '../widgets/top_pick_card.dart';
import '../widgets/mini_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/home_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch sound data when HomeScreen is mounted
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).fetchSoundData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final soundPlayerState = ref.watch(soundPlayerProvider);
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
                  const EnvironmentScanBanner(),

                  // Colored Noise List
                  Consumer(
                    builder: (context, ref, _) {
                      final homeState = ref.watch(homeViewModelProvider);
                      final soundPlayerNotifier = ref.read(soundPlayerProvider.notifier);
                      final coloredNoises = homeState.allSounds.where((sound) => sound.tags.contains(101)).toList();
                      return SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: coloredNoises.length,
                          itemBuilder: (context, index) {
                            final sound = coloredNoises[index];
                            final iconUrl = soundPlayerNotifier.googleDriveToDirect(sound.url_avatar);
                            return GestureDetector(
                              onTap: () {
                                final directUrl = soundPlayerNotifier.googleDriveToDirect(sound.url);
                                final directAvtUrl = soundPlayerNotifier.googleDriveToDirect(sound.url_avatar);
                                soundPlayerNotifier.showPlayer(
                                  sound: SoundModel(
                                    title: sound.title,
                                    url_avatar: directAvtUrl,
                                    url: directUrl,
                                    description: sound.description,
                                    tags: sound.tags,
                                  ),
                                );
                              },
                              child: NoiseTypeCard(
                                title: sound.title,
                                icon: iconUrl, // You can customize this based on sound
                                color: Colors.white, // Or assign a color based on sound
                              ),
                            );
                          },
                        ),
                      );
                    },
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
                  Consumer(
                    builder: (context, ref, _) {
                      final homeViewModel = ref.read(homeViewModelProvider.notifier);
                      final soundPlayerState = ref.watch(soundPlayerProvider);
                      final soundPlayerNotifier = ref.read(soundPlayerProvider.notifier);
                      final modes = [
                        {
                          'title': 'Easy Sleep',
                          'description': 'Calm your mind',
                          'icon': Icons.nightlight_round,
                          'color': Color(0xFF7B61FF),
                          'sounds': homeViewModel.sleepSounds,
                        },
                        {
                          'title': 'Relaxation',
                          'description': 'Reduce stress',
                          'icon': Icons.spa,
                          'color': Color(0xFFFF6161),
                          'sounds': homeViewModel.relaxSounds,
                        },
                        {
                          'title': 'Meditate',
                          'description': 'Find your center',
                          'icon': Icons.self_improvement,
                          'color': Color(0xFF61A3FF),
                          'sounds': homeViewModel.meditateSounds,
                        },
                        {
                          'title': 'Deep Work',
                          'description': 'Boost productivity',
                          'icon': Icons.psychology,
                          'color': Color(0xFF61A3FF),
                          'sounds': homeViewModel.deepworkSounds,
                        },
                        {
                          'title': 'Energy Boost',
                          'description': 'Feel energized',
                          'icon': Icons.bolt,
                          'color': Color(0xFFFFC300),
                          'sounds': homeViewModel.energyBoostSounds,
                        },
                        {
                          'title': 'Stress Relief',
                          'description': 'Let go of tension',
                          'icon': Icons.sentiment_satisfied,
                          'color': Color(0xFF00C896),
                          'sounds': homeViewModel.stressReliefSounds,
                        },
                        {
                          'title': 'Healing Body',
                          'description': 'Restore and heal',
                          'icon': Icons.healing,
                          'color': Color(0xFFB388FF),
                          'sounds': homeViewModel.healingBodySounds,
                        },
                      ];
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: modes.length,
                          itemBuilder: (context, index) {
                            final mode = modes[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/modeSounds',
                                  arguments: {
                                    'title': mode['title'] as String,
                                    'tag': _getTagForMode(mode['title'] as String),
                                  },
                                );
                              },
                              child: DailyModeCard(
                                title: mode['title'] as String,
                                description: mode['description'] as String,
                                icon: mode['icon'] as IconData,
                                color: mode['color'] as Color,
                              ),
                            );
                          },
                        ),
                      );
                    },
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
                      children: [
                        TopPickCard(
                          onTap: () => ref.read(soundPlayerProvider.notifier).showPlayer(
                            sound: SoundModel(
                              title: 'AAA',
                              url_avatar: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                              url: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
                              description: '',
                              tags: const []),
                          ),
                          title: 'Ocean Waves',
                          artist: 'Nature Sounds',
                          imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                          playCount: 1250000,
                        ),
                        const TopPickCard(
                          title: 'Rain Forest',
                          artist: 'Ambient Nature',
                          imageUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969',
                          playCount: 890000,
                        ),
                        const TopPickCard(
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
            if (soundPlayerState.sound != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(
                  title: soundPlayerState.sound?.title ?? '',
                  artist: '',
                  imageUrl: soundPlayerState.sound?.url_avatar ?? '',
                  isPlaying: soundPlayerState.isPlaying,
                  onPlayPause: () {
                    ref.read(soundPlayerProvider.notifier).togglePlayPause();
                  },
                  onTap: () {
                    ref.read(soundPlayerProvider.notifier).showPlayer();
                  },
                ),
              ),
            if (soundPlayerState.showPlayer)
              SoundPlayerUI(
                currentTime: soundPlayerState.currentTime,
                isPlaying: soundPlayerState.isPlaying,
                onCollapse: () => ref.read(soundPlayerProvider.notifier).collapse(),
                onLike: () => ref.read(soundPlayerProvider.notifier).like(),
                onPlayPause: () => ref.read(soundPlayerProvider.notifier).togglePlayPause(),
                onQueue: () {},
                sound: soundPlayerState.sound,
                totalDuration: soundPlayerState.timerDuration,
              ),
          ],
        ),
      ),
    );
  }

  int _getTagForMode(String title) {
    switch (title) {
      case 'Easy Sleep':
        return 202;
      case 'Relaxation':
        return 303;
      case 'Meditate':
        return 404;
      case 'Deep Work':
        return 505;
      case 'Energy Boost':
        return 606;
      case 'Stress Relief':
        return 707;
      case 'Healing Body':
        return 808;
      default:
        return 0;
    }
  }
}