import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mytune/core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytune/features/sound_player/models/sound_model.dart';
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
}

final myTuneRecentsViewModelProvider = NotifierProvider<MyTuneRecentsViewModel, List<SoundModel>>(MyTuneRecentsViewModel.new); 