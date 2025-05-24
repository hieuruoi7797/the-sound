package com.splat.mytune

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: AudioServiceActivity() {
    private lateinit var recordingHandler: RecordingHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        recordingHandler = RecordingHandler(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.splat.mytune/recording")
            .setMethodCallHandler { call, result ->
                print("hieuttcheckMETHOD")
                recordingHandler.onMethodCall(call, result)
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.splat.mytune/frequency")
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
