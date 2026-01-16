import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:mytune/features/sound_player/viewmodels/soundplayer_view_model.dart';
import 'package:mytune/features/sound_player/views/sound_player_ui.dart';
import 'package:mytune/features/home/widgets/mini_player.dart';
import 'package:mytune/features/my_tune/my_tune_view_model.dart';
import 'package:mytune/features/home/viewmodels/home_view_model.dart';
import 'package:mytune/core/widgets/optimized_avatar_image.dart';

class MyTuneView extends ConsumerStatefulWidget {
  const MyTuneView({super.key});

  @override
  ConsumerState<MyTuneView> createState() => _MyTuneViewState();
}

class _MyTuneViewState extends ConsumerState<MyTuneView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1 && _tabController.indexIsChanging) {
      ref.read(myTuneViewModelProvider.notifier).refreshFavorites();
    }
    if (_tabController.index == 0 && _tabController.indexIsChanging) {
      ref.read(myTuneRecentsViewModelProvider.notifier).refreshRecents();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soundPlayerState = ref.watch(soundPlayerProvider);
    final favorites = ref.watch(myTuneViewModelProvider);
    final recents = ref.watch(myTuneRecentsViewModelProvider);

    return DefaultTabController(
      length: 2,
      child: (soundPlayerState.showPlayer)?
                SoundPlayerUI(
                  currentTime: soundPlayerState.currentTime,
                  isPlaying: soundPlayerState.isPlaying,
                  onCollapse: () => ref.read(soundPlayerProvider.notifier).collapse(),
                  onLike: () => ref.read(soundPlayerProvider.notifier).like(),
                  onPlayPause: () => ref.read(soundPlayerProvider.notifier).togglePlayPause(),
                  sound: soundPlayerState.sound,
                  totalDuration: soundPlayerState.timerDuration,
                ):Scaffold(
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
          actions: [
            // Refresh button (only show in debug mode)
            if (kDebugMode)
              IconButton(
                onPressed: () async {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Syncing local data...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Sync local data with database
                  await ref.read(homeViewModelProvider.notifier).syncLocalData();
                  
                  // Refresh the current tab
                  if (_tabController.index == 0) {
                    ref.read(myTuneRecentsViewModelProvider.notifier).refreshRecents();
                  } else {
                    ref.read(myTuneViewModelProvider.notifier).refreshFavorites();
                  }
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Local data synced!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.sync,
                  color: Colors.white70,
                ),
                tooltip: 'Sync Local Data',
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
                controller: _tabController,
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
                controller: _tabController,
                children: [
                  _buildGridView(context, recents),
                  _buildGridView(context, favorites),
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
          childAspectRatio: (MediaQuery.of(context).size.width * 0.4) / (MediaQuery.of(context).size.width * 0.4),
        ),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final sound = sounds[index];
          final soundPlayerNotifier = ref.read(soundPlayerProvider.notifier);
          return GestureDetector(
            onTap: () {
              ref.read(soundPlayerProvider.notifier).showPlayer(sound: sound);
            },
            child: OptimizedSquareImage(
              imageUrl: soundPlayerNotifier.googleDriveToDirect(sound.url_avatar),
              size: (MediaQuery.of(context).size.width * 0.4),
              borderRadius: BorderRadius.circular(10),
              overlay: Stack(
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