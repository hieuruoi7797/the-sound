import 'package:firebase_database/firebase_database.dart';
import '../models/sound_model.dart';

class SoundRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sounds');

  Future<String> addSound(SoundModel sound) async {
    final newRef = _dbRef.push();
    await newRef.set(sound.toJson());
    return newRef.key!;
  }

  Future<List<SoundModel>> getSounds() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.values
          .map((e) => SoundModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> updateSound(String key, SoundModel sound) async {
    await _dbRef.child(key).set(sound.toJson());
  }

  Future<void> deleteSound(String key) async {
    await _dbRef.child(key).remove();
  }
} 