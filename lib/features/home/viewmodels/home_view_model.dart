import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/data/realtime_database_service.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:mytune/core/services/image_preloader_service.dart';
import 'package:mytune/core/config/app_config.dart';
import 'package:mytune/core/services/cache_management_service.dart';
import 'package:mytune/features/my_tune/my_tune_view_model.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeState {
  final List<SoundModel> allSounds;
  final List<SoundModel> topPicks;
  final List<SoundModel> topPicksAll;
  final bool isLoading;
  final String? error;

  HomeState({
    this.allSounds = const [],
    this.isLoading = false,
    this.topPicks = const [],
    this.topPicksAll = const [],
    this.error,
  });

  HomeState copyWith({
    List<SoundModel>? allSounds,
    bool? isLoading,
    List<SoundModel>? topPicks,
    List<SoundModel>? topPicksAll,
    String? error,
  }) {
    return HomeState(
      allSounds: allSounds ?? this.allSounds,
      isLoading: isLoading ?? this.isLoading,
      topPicks: topPicks ?? this.topPicks,
      topPicksAll: topPicksAll ?? this.topPicksAll,
      error: error,
    );
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref);
});

class HomeViewModel extends StateNotifier<HomeState> {
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  final Ref _ref;
  StreamSubscription<DatabaseEvent>? _topPicksSub;

  HomeViewModel(this._ref) : super(HomeState());

  void fetchSoundData() {
    print('[HomeViewModel] Fetching sound data from root...');
    print('[HomeViewModel] Using database URL: ${AppConfig.databaseUrl}');
    print('[HomeViewModel] Environment: ${AppConfig.environment.name}');
    
    state = state.copyWith(isLoading: true, error: null);
    _topPicksSub?.cancel();
    
    if (!_dbService.isInitialized) {
      print('[HomeViewModel] Database not initialized, using empty data');
      state = state.copyWith(allSounds: [], isLoading: false, error: 'Database not available');
      return;
    }
    
    _topPicksSub = _dbService.readData('').listen((event) {
      try {
        final data = event.snapshot.value;
        print('[HomeViewModel] Data snapshot received:');
        print(data);
        if (data is Map) {
          final systemSounds = SystemSoundsModel.fromJson(Map<String, dynamic>.from(data));
          print('[HomeViewModel] Parsed ${systemSounds.sounds.length} sounds from SystemSoundsModel');
          
          // Check if avatar URLs have changed and clear cache if needed
          _checkAndUpdateImageCache(systemSounds.sounds);
          
          // Sync local data (recents and favorites) with new database data
          _syncLocalDataWithDatabase(systemSounds.sounds);
          
          state = state.copyWith(allSounds: systemSounds.sounds, isLoading: false, error: null);
          makeTopPicks();
        } else {
          print('[HomeViewModel] No valid data found.');
          state = state.copyWith(allSounds: [], isLoading: false, error: null);
          makeTopPicks();
        }
        print('[HomeViewModel] State updated: topPicks=${state.allSounds.length}, isLoading=${state.isLoading}, error=${state.error}');
      } catch (e) {
        print('[HomeViewModel] Error parsing data: $e');
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }, onError: (e) {
      print('[HomeViewModel] Error fetching data: $e');
      
      // Provide more specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('permission-denied')) {
        if (AppConfig.isDev) {
          errorMessage = 'Dev database not accessible. Please:\n1. Import data to dev database\n2. Check Firebase security rules\n3. Verify database URL: ${AppConfig.databaseUrl}';
        } else {
          errorMessage = 'Permission denied. Check Firebase security rules.';
        }
      }
      
      state = state.copyWith(isLoading: false, error: errorMessage);
    });
  }

  /// Sync local data (recents and favorites) with database
  void _syncLocalDataWithDatabase(List<SoundModel> databaseSounds) {
    // Sync recents
    _ref.read(myTuneRecentsViewModelProvider.notifier).syncRecentsWithDatabase(databaseSounds);
    
    // Sync favorites
    _ref.read(myTuneViewModelProvider.notifier).syncFavoritesWithDatabase(databaseSounds);
  }

  /// Check if avatar URLs have changed and clear cache if needed
  void _checkAndUpdateImageCache(List<SoundModel> newSounds) {
    // Create a simple hash of all avatar URLs to detect changes
    final newAvatarUrls = newSounds.map((s) => s.url_avatar).join('|');
    final newHash = newAvatarUrls.hashCode.toString();
    
    // Check data version and clear cache if changed
    CacheManagementService.checkDataVersionAndClearCache(newHash);
  }

  /// Force refresh all cached images
  Future<void> refreshImageCache() async {
    print('[HomeViewModel] Force refreshing image cache...');
    await CacheManagementService.forceRefreshCache();
    print('[HomeViewModel] Image cache refreshed');
  }

  /// Force sync local data with current database data
  Future<void> syncLocalData() async {
    if (state.allSounds.isNotEmpty) {
      print('[HomeViewModel] Syncing local data with database...');
      _syncLocalDataWithDatabase(state.allSounds);
      print('[HomeViewModel] Local data synced');
    }
  }

  @override
  void dispose() {
    _topPicksSub?.cancel();
    super.dispose();
  }

  // Add getters for each mode's sound list
  List<SoundModel> get sleepSounds => state.allSounds.where((s) => s.tags.contains(202)).toList();
  List<SoundModel> get relaxSounds => state.allSounds.where((s) => s.tags.contains(303)).toList();
  List<SoundModel> get meditateSounds => state.allSounds.where((s) => s.tags.contains(404)).toList();
  List<SoundModel> get deepworkSounds => state.allSounds.where((s) => s.tags.contains(505)).toList();
  List<SoundModel> get energyBoostSounds => state.allSounds.where((s) => s.tags.contains(606)).toList();
  List<SoundModel> get stressReliefSounds => state.allSounds.where((s) => s.tags.contains(707)).toList();
  List<SoundModel> get healingBodySounds => state.allSounds.where((s) => s.tags.contains(808)).toList();
  List<SoundModel> get topPicksAll => state.topPicksAll;

  void makeTopPicks() {
    // Shuffle and pick 5 random sounds
    final randomSounds = List<SoundModel>.from(state.allSounds)..shuffle();
    final topPicksAll = randomSounds.take(50).toList();
    final topPicks = topPicksAll.take(5).toList();
    state = state.copyWith(
      topPicks: topPicks,
      topPicksAll: topPicksAll,
    );
    print('[HomeViewModel] Top picks made: ${topPicks.length} from ${topPicksAll.length} total sounds');
  }

  /// Preload images for sounds in a specific category
  Future<void> preloadCategoryImages(int tag, BuildContext context) async {
    List<SoundModel> sounds;
    switch (tag) {
      case 202:
        sounds = sleepSounds;
        break;
      case 303:
        sounds = relaxSounds;
        break;
      case 404:
        sounds = meditateSounds;
        break;
      case 505:
        sounds = deepworkSounds;
        break;
      case 606:
        sounds = energyBoostSounds;
        break;
      case 707:
        sounds = stressReliefSounds;
        break;
      case 808:
        sounds = healingBodySounds;
        break;
      default:
        sounds = topPicksAll;
    }
    
    if (sounds.isNotEmpty) {
      final imageUrls = sounds
          .where((sound) => sound.url_avatar.isNotEmpty)
          .map((sound) => sound.url_avatar)
          .toList();
      
      if (imageUrls.isNotEmpty) {
        await ImagePreloaderService().preloadImages(imageUrls, context);
      }
    }
  }
}

class SystemSoundsModel {
  final List<SoundModel> sounds;

  SystemSoundsModel({required this.sounds});

  factory SystemSoundsModel.fromJson(Map<String, dynamic> json) {
    final dynamic raw = json['system_sounds'];
    List<SoundModel> sounds = [];
    if (raw is List) {
      // If the data is a list, use index as soundId
      sounds = raw.asMap().entries
          .where((entry) => entry.value is Map)
          .map((entry) => SoundModel.fromJson(Map<String, dynamic>.from(entry.value), soundId: entry.key))
          .toList();
    } else if (raw is Map) {
      // If the data is a map, use the last integer part of the key as soundId
      sounds = raw.entries
          .where((entry) => entry.value is Map)
          .map((entry) {
            final key = entry.key.toString();
            // Lấy số cuối cùng sau dấu _ trong key, ví dụ sound_id_11 => 11
            final match = RegExp(r'_(\d+)$').firstMatch(key);
            final soundId = match != null ? int.parse(match.group(1)!) : 0;
            return SoundModel.fromJson(Map<String, dynamic>.from(entry.value), soundId: soundId);
          })
          .toList();
    }
    return SystemSoundsModel(sounds: sounds);
  }

  Map<String, dynamic> toJson() {
    return {
      'system_sounds': sounds.map((e) => e.toJson()).toList(),
    };
  }
}