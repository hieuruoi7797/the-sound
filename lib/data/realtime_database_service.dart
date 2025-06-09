import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: "https://my-tune-1ac48-default-rtdb.asia-southeast1.firebasedatabase.app");

  RealtimeDatabaseService() {
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10 * 1024 * 1024); // 10MB cache
  }

  // Method to get a reference to a specific path in the database
  DatabaseReference getReference(String path) {
    return _database.ref(path);
  }

  // Method to write data to a specific path
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _database.ref(path).set(data);
  }

  // Method to read data from a specific path
  Stream<DatabaseEvent> readData(String path) {
    return _database.ref(path).onValue;
  }

  // Method to update data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _database.ref(path).update(data);
  }

  // Method to delete data at a specific path
  Future<void> deleteData(String path) async {
    await _database.ref(path).remove();
  }

  // Example of handling data from a stream
  static T? parseSnapshot<T>(DatabaseEvent event, T Function(Map<String, dynamic>) fromJson) {
    final data = event.snapshot.value;
    if (data is Map<dynamic, dynamic>) {
      return fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
} 