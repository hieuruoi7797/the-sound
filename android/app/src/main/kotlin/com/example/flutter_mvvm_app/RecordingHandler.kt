package com.example.flutter_mvvm_app

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlin.math.abs

class RecordingHandler(private val activity: Activity) {
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var recordingJob: Job? = null
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        private const val PERMISSION_REQUEST_CODE = 123
        private const val SAMPLE_RATE = 44100
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
    }

    fun onMethodCall(call: MethodChannel.Result, method: String) {
        when (method) {
            "requestPermission" -> checkPermission(call)
            "checkPermissionStatus" -> checkPermissionStatus(call)
            "startRecording" -> startRecording(call)
            "stopRecording" -> stopRecording(call)
            else -> call.notImplemented()
        }
    }

    fun onListen(events: EventChannel.EventSink?) {
        eventSink = events
    }

    fun onCancel(events: EventChannel.EventSink?) {
        eventSink = null
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && 
                         grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun checkPermissionStatus(result: MethodChannel.Result) {
        val hasPermission = ContextCompat.checkSelfPermission(
            activity,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        result.success(hasPermission)
    }

    private fun checkPermission(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
        } else {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                PERMISSION_REQUEST_CODE
            )
            // Don't send result here, we'll send it from onRequestPermissionsResult
            // Store the result object to use later
            pendingPermissionResult = result
        }
    }

    private fun startRecording(result: MethodChannel.Result) {
        if (isRecording) {
            result.error("ALREADY_RECORDING", "Recording is already in progress", null)
            return
        }

        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            CHANNEL_CONFIG,
            AUDIO_FORMAT
        )

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            CHANNEL_CONFIG,
            AUDIO_FORMAT,
            bufferSize
        )

        if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
            result.error("INIT_FAILED", "Failed to initialize AudioRecord", null)
            return
        }

        isRecording = true
        audioRecord?.startRecording()

        recordingJob = CoroutineScope(Dispatchers.IO).launch {
            val buffer = ShortArray(bufferSize)
            while (isRecording) {
                val readSize = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (readSize > 0) {
                    // Calculate average amplitude
                    var sum = 0.0
                    for (i in 0 until readSize) {
                        sum += abs(buffer[i].toDouble())
                    }
                    val average = sum / readSize
                    
                    // Send to Flutter
                    withContext(Dispatchers.Main) {
                        eventSink?.success(average)
                    }
                }
                delay(50) // Update frequency every 50ms
            }
        }

        result.success(null)
    }

    private fun stopRecording(result: MethodChannel.Result) {
        isRecording = false
        recordingJob?.cancel()
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        result.success(null)
    }
} 