import 'package:flutter/services.dart';

class RecordingService {
  static const platform = MethodChannel('com.splat.mytune/recording');
  static const eventChannel = EventChannel('com.splat.mytune/frequency');

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
      print("hieuttcheckPermissionStatus");
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
} 