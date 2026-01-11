import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class MyTuneViewModel extends Notifier<List<SoundModel>> {

  @override
  List<SoundModel> build() {
    _loadFavorites();
    return [];
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = prefs.getStringList(AppStrings.favoritesKey) ?? [];
    final favs = favJson.map((e) => SoundModel.fromJson(jsonDecode(e))).toList();
    state = favs;
  }

  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }

  /// Update favorites with new data from database (sync avatar URLs)
  Future<void> syncFavoritesWithDatabase(List<SoundModel> databaseSounds) async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = prefs.getStringList(AppStrings.favoritesKey) ?? [];
    
    if (favJson.isEmpty) return;
    
    List<SoundModel> updatedFavorites = [];
    bool hasChanges = false;
    
    for (String jsonString in favJson) {
      final localSound = SoundModel.fromJson(jsonDecode(jsonString));
      
      // Find matching sound in database by soundId
      final databaseSound = databaseSounds.firstWhere(
        (dbSound) => dbSound.soundId == localSound.soundId,
        orElse: () => localSound,
      );
      
      // Check if avatar URL has changed
      if (databaseSound.url_avatar != localSound.url_avatar) {
        debugPrint('🔄 Updating favorite sound ${localSound.soundId}: ${localSound.url_avatar} -> ${databaseSound.url_avatar}');
        updatedFavorites.add(databaseSound);
        hasChanges = true;
      } else {
        updatedFavorites.add(localSound);
      }
    }
    
    if (hasChanges) {
      // Save updated favorites back to SharedPreferences
      final updatedJson = updatedFavorites.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(AppStrings.favoritesKey, updatedJson);
      
      // Update state
      state = updatedFavorites;
      debugPrint('✅ Favorites synced with database');
    }
  }
}

final myTuneViewModelProvider = NotifierProvider<MyTuneViewModel, List<SoundModel>>(MyTuneViewModel.new); 

// Recents Notifier
class MyTuneRecentsViewModel extends Notifier<List<SoundModel>> {
  @override
  List<SoundModel> build() {
    _loadRecents();
    return [];
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final recentsJson = prefs.getStringList(AppStrings.recentsKey) ?? [];
    final recents = recentsJson.map((e) => SoundModel.fromJson(jsonDecode(e))).toList();
    state = recents;
  }

  Future<void> refreshRecents() async {
    await _loadRecents();
  }

  /// Update recents with new data from database (sync avatar URLs)
  Future<void> syncRecentsWithDatabase(List<SoundModel> databaseSounds) async {
    final prefs = await SharedPreferences.getInstance();
    final recentsJson = prefs.getStringList(AppStrings.recentsKey) ?? [];
    
    if (recentsJson.isEmpty) return;
    
    List<SoundModel> updatedRecents = [];
    bool hasChanges = false;
    
    for (String jsonString in recentsJson) {
      final localSound = SoundModel.fromJson(jsonDecode(jsonString));
      
      // Find matching sound in database by soundId
      final databaseSound = databaseSounds.firstWhere(
        (dbSound) => dbSound.soundId == localSound.soundId,
        orElse: () => localSound,
      );
      
      // Check if avatar URL has changed
      if (databaseSound.url_avatar != localSound.url_avatar) {
        debugPrint('🔄 Updating recent sound ${localSound.soundId}: ${localSound.url_avatar} -> ${databaseSound.url_avatar}');
        updatedRecents.add(databaseSound);
        hasChanges = true;
      } else {
        updatedRecents.add(localSound);
      }
    }
    
    if (hasChanges) {
      // Save updated recents back to SharedPreferences
      final updatedJson = updatedRecents.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(AppStrings.recentsKey, updatedJson);
      
      // Update state
      state = updatedRecents;
      debugPrint('✅ Recents synced with database');
    }
  }
}

final myTuneRecentsViewModelProvider = NotifierProvider<MyTuneRecentsViewModel, List<SoundModel>>(MyTuneRecentsViewModel.new); 