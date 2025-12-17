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
import '../widgets/scan_note_card.dart';
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
    return  
     (soundPlayerState.showPlayer)?
              SoundPlayerUI(
                currentTime: soundPlayerState.currentTime,
                isPlaying: soundPlayerState.isPlaying,
                onCollapse: () => ref.read(soundPlayerProvider.notifier).collapse(),
                onLike: () => ref.read(soundPlayerProvider.notifier).like(),
                onPlayPause: () => ref.read(soundPlayerProvider.notifier).togglePlayPause(),
                sound: soundPlayerState.sound,
                totalDuration: soundPlayerState.timerDuration,
              ):
              Scaffold(
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
                      // const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(),
                      // IconButton(
                      //   onPressed: () {
                      //     // Navigate to Profile/Settings
                      //   },
                      //   icon: Container(
                      //     padding: const EdgeInsets.all(8),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white.withOpacity(0.1),
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: const Icon(
                      //       Icons.person,
                      //       color: Colors.white,
                      //       size: 20,
                      //     ),
                      //   ),
                      // ),
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
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final sound = coloredNoises[index];
                            final iconUrl = soundPlayerNotifier.googleDriveToDirect(sound.url_avatar);
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    soundPlayerNotifier.showPlayer(
                                      sound: sound,
                                    );
                                  },
                                  child: NoiseTypeCard(
                                    title: sound.title,
                                    icon: iconUrl, // You can customize this based on sound
                                    color: Colors.white, // Or assign a color based on sound
                                  ),
                                ),
                                if (index != coloredNoises.length - 1)
                                  const SizedBox(width: 16),
                              ],
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
                      final modes = [
                        {
                          'title': 'Easy Sleep',
                          'description': 'Calm your mind',
                          'icon': Icons.nightlight_round,
                          'color': Color(0xFF7B61FF),
                          'sounds': homeViewModel.sleepSounds,
                          'assetSvg': Assets.easySleep,
                        },
                        {
                          'title': 'Relax',
                          'description': 'Reduce stress',
                          'icon': Icons.spa,
                          'color': Color(0xFFFF6161),
                          'sounds': homeViewModel.relaxSounds,
                          'assetSvg': Assets.relax,
                        },
                        {
                          'title': 'Stress Relief',
                          'description': 'Find your center',
                          'icon': Icons.self_improvement,
                          'color': Color(0xFF61A3FF),
                          'sounds': homeViewModel.stressReliefSounds,
                          'assetSvg': Assets.stress_relief,
                        },
                        {
                          'title': 'Deep Work',
                          'description': 'Boost productivity',
                          'icon': Icons.psychology,
                          'color': Color(0xFF61A3FF),
                          'sounds': homeViewModel.deepworkSounds,
                          'assetSvg': Assets.deep_work,
                        },
                        {
                          'title': 'Energy Boost',
                          'description': 'Feel energized',
                          'icon': Icons.bolt,
                          'color': Color(0xFFFFC300),
                          'sounds': homeViewModel.energyBoostSounds,
                          'assetSvg': Assets.energy_boost,
                        },
                        {
                          'title': 'Meditate',
                          'description': 'Let go of tension',
                          'icon': Icons.sentiment_satisfied,
                          'color': Color(0xFF00C896),
                          'sounds': homeViewModel.meditateSounds,
                          'assetSvg': Assets.meditate,
                        },
                        {
                          'title': 'Body Healing',
                          'description': 'Restore and heal',
                          'icon': Icons.healing,
                          'color': Color(0xFFB388FF),
                          'sounds': homeViewModel.healingBodySounds,
                          'assetSvg': Assets.body_healing,
                        },
                      ];
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
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
                                assetSvg: mode['assetSvg'] as String,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Top Picks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top Picks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/modeSounds', arguments: {
                          'title': 'Top Picks',
                          'tag': 000, // Assuming 101 is the tag for top picks
                        }),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFF7E7B8F),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final homeState = ref.watch(homeViewModelProvider);
                      final soundPlayerNotifier = ref.read(soundPlayerProvider.notifier);

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.14,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeState.topPicks.length,
                          itemBuilder: (context,index) {
                            final sound = homeState.topPicks[index];
                            return TopPickCard(
                              onTap: () => soundPlayerNotifier.showPlayer(sound: sound),
                              title: sound.title,
                              artist: '', // Use appropriate field if available
                              imageUrl: soundPlayerNotifier.googleDriveToDirect(sound.url_avatar)
                            );
                          },
                        ),
                      );
                    }
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
                  imageUrl: ref.read(soundPlayerProvider.notifier).googleDriveToDirect(soundPlayerState.sound?.url_avatar ?? ''),
                  isPlaying: soundPlayerState.isPlaying,
                  onPlayPause: () {
                    ref.read(soundPlayerProvider.notifier).togglePlayPause();
                  },
                  onTap: () {
                    ref.read(soundPlayerProvider.notifier).showPlayer();
                  },
                ),
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