import 'package:flutter/services.dart';
import '../../../data/realtime_database_service.dart';
import '../models/frequencies_data_model.dart';
import 'dart:math';

class RecordingService {
  static const platform = MethodChannel('com.splat.mytune/recording');
  static const eventChannel = EventChannel('com.splat.mytune/frequency');

  final RealtimeDatabaseService _databaseService;

  RecordingService(this._databaseService);

  Future<bool> requestPermission() async {
    try {
      print("hieuttrequestPermission");
      final bool hasPermission = await platform.invokeMethod('requestPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('Failed to request permission: ${e.message}');
      return false;
    }
  }

  Future<bool> checkPermissionStatus() async {
    try {
      final bool hasPermission = await platform.invokeMethod('checkPermissionStatus');
      print("hieuttcheckPermissionStatus $hasPermission");
      return hasPermission;
    } on PlatformException catch (e) {
      print('Failed to check permission status: ${e.message}');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      await platform.invokeMethod('startRecording');
    } on PlatformException catch (e) {
      print('Failed to start recording: ${e.message}');
      throw Exception('Failed to start recording');
    }
  }

  Future<void> stopRecording() async {
    try {
      await platform.invokeMethod('stopRecording');
    } on PlatformException catch (e) {
      print('Failed to stop recording: ${e.message}');
      throw Exception('Failed to stop recording');
    }
  }

  Stream<double> get frequencyStream {
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      return event as double;
    });
  }

  Future<String?> getFrequencyDescription(double frequency) async {
    try {
      final event = await _databaseService.readData("").first;
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        final frequenciesData = FrequenciesDataModel.fromJson( Map<String, dynamic>.from(data));
        for (var entry in frequenciesData.frequencies.entries) {
          final freqModel = entry.value;
          if (frequency >= freqModel.range[0] && frequency <= freqModel.range[1]) {
            // Found a matching range, return a random feedback
            final random = Random();
            final feedback = freqModel.feedback[random.nextInt(freqModel.feedback.length)];
            return feedback.replaceAll('{{hz}}', frequency.round().toString());
          }
        }
      }
    } catch (e) {
      print('Error fetching frequency description: $e');
    }
    return null;
  }
} 