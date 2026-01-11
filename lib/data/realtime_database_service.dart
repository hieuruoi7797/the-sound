import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';

class RealtimeDatabaseService {
  late final FirebaseDatabase _database;
  bool _isInitialized = false;

  RealtimeDatabaseService() {
    _initializeDatabase();
  }

  void _initializeDatabase() {
    try {
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(), 
        databaseURL: AppConfig.databaseUrl
      );
      _database.setPersistenceEnabled(true);
      _database.setPersistenceCacheSizeBytes(10 * 1024 * 1024); // 10MB cache
      _isInitialized = true;
      debugPrint("✅ RealtimeDatabaseService initialized successfully with ${AppConfig.environment.name} database: ${AppConfig.databaseUrl}");
    } catch (e) {
      debugPrint("❌ Failed to initialize RealtimeDatabaseService: $e");
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;

  // Method to get a reference to a specific path in the database
  DatabaseReference? getReference(String path) {
    if (!_isInitialized) {
      debugPrint("❌ Database not initialized, cannot get reference");
      return null;
    }
    try {
      // Handle empty path or root path
      if (path.isEmpty || path == '/') {
        return _database.ref();
      }
      return _database.ref(path);
    } catch (e) {
      debugPrint("❌ Error getting database reference for path '$path': $e");
      return null;
    }
  }

  // Method to write data to a specific path
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    if (!_isInitialized) {
      debugPrint("❌ Database not initialized, cannot write data");
      return;
    }
    try {
      if (path.isEmpty || path == '/') {
        await _database.ref().set(data);
      } else {
        await _database.ref(path).set(data);
      }
    } catch (e) {
      debugPrint("❌ Error writing data to path '$path': $e");
    }
  }

  // Method to read data from a specific path
  Stream<DatabaseEvent> readData(String path) {
    if (!_isInitialized) {
      debugPrint("❌ Database not initialized, returning empty stream");
      return const Stream.empty();
    }
    try {
      if (path.isEmpty || path == '/') {
        return _database.ref().onValue;
      }
      return _database.ref(path).onValue;
    } catch (e) {
      debugPrint("❌ Error reading data from path '$path': $e");
      return const Stream.empty();
    }
  }

  // Method to update data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    if (!_isInitialized) {
      debugPrint("❌ Database not initialized, cannot update data");
      return;
    }
    try {
      if (path.isEmpty || path == '/') {
        await _database.ref().update(data);
      } else {
        await _database.ref(path).update(data);
      }
    } catch (e) {
      debugPrint("❌ Error updating data at path '$path': $e");
    }
  }

  // Method to delete data at a specific path
  Future<void> deleteData(String path) async {
    if (!_isInitialized) {
      debugPrint("❌ Database not initialized, cannot delete data");
      return;
    }
    try {
      if (path.isEmpty || path == '/') {
        await _database.ref().remove();
      } else {
        await _database.ref(path).remove();
      }
    } catch (e) {
      debugPrint("❌ Error deleting data at path '$path': $e");
    }
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