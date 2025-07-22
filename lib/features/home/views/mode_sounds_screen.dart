import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';
import 'package:mytune/features/sound_player/views/sound_player_ui.dart';
import 'package:mytune/features/home/widgets/mini_player.dart';
import '../viewmodels/home_view_model.dart';

class ModeSoundsScreen extends ConsumerWidget {
  final String title;
  final int tag;
  const ModeSoundsScreen({
    required this.title,
    required this.tag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final soundPlayerState = ref.watch(soundPlayerProvider);
    final soundPlayerNotifier = ref.read(soundPlayerProvider.notifier);
    List<SoundModel> sounds;
    switch (tag) {
      case 202:
        sounds = homeViewModel.sleepSounds;
        break;
      case 303:
        sounds = homeViewModel.relaxSounds;
        break;
      case 404:
        sounds = homeViewModel.meditateSounds;
        break;
      case 505:
        sounds = homeViewModel.deepworkSounds;
        break;
      case 606:
        sounds = homeViewModel.energyBoostSounds;
        break;
      case 707:
        sounds = homeViewModel.stressReliefSounds;
        break;
      case 808:
        sounds = homeViewModel.healingBodySounds;
        break;
      default:
        sounds = [];
    }
    return Scaffold(
      backgroundColor: const Color(0xFF141318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141318),
        elevation: 0,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: (MediaQuery.of(context).size.width * 0.4) / (MediaQuery.of(context).size.height * 0.22),
                ),
                itemCount: sounds.length,
                itemBuilder: (context, index) {
                  final sound = sounds[index];
                  final directUrl = soundPlayerNotifier.googleDriveToDirect(sound.url);
                  final directAvtUrl = soundPlayerNotifier.googleDriveToDirect(sound.url_avatar);
                  return GestureDetector(
                    onTap: () {
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(directAvtUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Text(
                              sound.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
                    soundPlayerNotifier.togglePlayPause();
                  },
                  onTap: () {
                    soundPlayerNotifier.showPlayer();
                  },
                ),
              ),
            if (soundPlayerState.showPlayer)
              SoundPlayerUI(
                currentTime: soundPlayerState.currentTime,
                isPlaying: soundPlayerState.isPlaying,
                onCollapse: () => soundPlayerNotifier.collapse(),
                onLike: () => soundPlayerNotifier.like(),
                onPlayPause: () => soundPlayerNotifier.togglePlayPause(),
                onQueue: () {},
                sound: soundPlayerState.sound,
                totalDuration: soundPlayerState.timerDuration,
              ),
          ],
        ),
      ),
    );
  }
} 