import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';
import 'package:mytune/features/sound_player/views/sound_player_ui.dart';
import 'package:mytune/features/home/widgets/mini_player.dart';

class MyTuneView extends ConsumerWidget {
  const MyTuneView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundPlayerState = ref.watch(soundPlayerProvider);
    final List<SoundModel> mockSounds = [
      SoundModel(
        title: 'Pink Noise 1',
        url_avatar: 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484',
        url: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
        description: 'Mock sound 1',
        tags: const [],
      ),
      SoundModel(
        title: 'Pink Noise 2',
        url_avatar: 'https://images.unsplash.com/photo-1511497584788-876760111969',
        url: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
        description: 'Mock sound 2',
        tags: const [],
      ),
      SoundModel(
        title: 'Pink Noise 3',
        url_avatar: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        url: 'https://drive.google.com/file/d/1yGdpJIWuDKff_hChF1XGUj4YSoE0E2xJ/view?usp=sharing',
        description: 'Mock sound 3',
        tags: const [],
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF141318),
        appBar: AppBar(
          backgroundColor: const Color(0xFF141318),
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text(
            'My Tune',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 16), // Adjusted height for padding
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
                // isScrollable: true,
                indicator: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(24),
                ),
                indicatorColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Recents'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                children: [
                  _buildGridView(context, mockSounds),
                  _buildGridView(context, mockSounds), // Same mock data for favorites for now
                ],
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
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<SoundModel> sounds) {
    return Padding(
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
          return GestureDetector(
            onTap: () {
              // Handle sound item tap
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(sound.url_avatar),
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
    );
  }
} 