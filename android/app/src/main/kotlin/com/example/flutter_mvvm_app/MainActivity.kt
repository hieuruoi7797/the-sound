package com.example.flutter_mvvm_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private lateinit var recordingHandler: RecordingHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        recordingHandler = RecordingHandler(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.flutter_mvvm_app/recording")
            .setMethodCallHandler { call, result ->
                recordingHandler.onMethodCall(result, call.method)
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.flutter_mvvm_app/frequency")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    recordingHandler.onListen(events)
                }

                override fun onCancel(arguments: Any?) {
                    recordingHandler.onCancel(null)
                }
            })
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        recordingHandler.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
