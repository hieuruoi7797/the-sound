import Flutter
import UIKit
import AVFoundation
import Accelerate

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  var audioRecorder: AVAudioRecorder?
  var audioEngine: AVAudioEngine?
  var methodChannel: FlutterMethodChannel?
  var isRecording: Bool = false
  var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.splat.mytune/recording",
                                      binaryMessenger: controller.binaryMessenger)
    self.methodChannel = channel
    channel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      if call.method == "requestPermission" {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async {
            result(granted)
          }
        }
      } else if call.method == "checkPermissionStatus" {
        let status = AVAudioSession.sharedInstance().recordPermission
        result(status == .granted)
      } else if call.method == "startRecording" {
        self.startAudioEngine(result: result)
      } else if call.method == "stopRecording" {
        self.stopAudioEngine(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    // Set up EventChannel for frequency streaming
    let eventChannel = FlutterEventChannel(name: "com.splat.mytune/frequency", binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // FlutterStreamHandler methods
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  private func startAudioEngine(result: @escaping FlutterResult) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
      try audioSession.setActive(true)
      audioEngine = AVAudioEngine()
      let inputNode = audioEngine!.inputNode
      let bus = 0
      let inputFormat = inputNode.inputFormat(forBus: bus)
      let bufferSize: AVAudioFrameCount = 2048
      inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: inputFormat) { [weak self] (buffer, time) in
        guard let self = self else { return }
        if let freq = self.extractFrequency(from: buffer, sampleRate: Float(inputFormat.sampleRate)) {
              print("Extracted frequency: \(freq)")
          DispatchQueue.main.async {
            self.eventSink?(freq)
          }
        }
      }
      audioEngine?.prepare()
      try audioEngine?.start()
      isRecording = true
      result(true)
    } catch {
      print("Failed to start audio engine: \(error)")
      result(false)
    }
  }

  private func stopAudioEngine(result: @escaping FlutterResult) {
    audioEngine?.inputNode.removeTap(onBus: 0)
    audioEngine?.stop()
    audioEngine = nil
    isRecording = false
    result(true)
  }

 private func extractFrequency(from buffer: AVAudioPCMBuffer, sampleRate: Float) -> Double? {
    guard let channelData = buffer.floatChannelData?[0] else { return nil }
    let frameLength = Int(buffer.frameLength)
    let log2n = UInt(round(log2(Double(frameLength))))
    let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
    var realp = [Float](repeating: 0, count: frameLength/2)
    var imagp = [Float](repeating: 0, count: frameLength/2)
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
    channelData.withMemoryRebound(to: DSPComplex.self, capacity: frameLength) { typeConvertedTransferBuffer in
        vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(frameLength/2))
    }
    vDSP_fft_zrip(fftSetup!, &output, 1, log2n, Int32(FFT_FORWARD))
    var magnitudes = [Float](repeating: 0.0, count: frameLength/2)
    vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(frameLength/2))
    var maxMag: Float = 0
    var maxIndex: vDSP_Length = 0
    // Skip the first few bins to avoid DC component
    let searchRange = 1..<magnitudes.count
    for i in searchRange {
        if magnitudes[i] > maxMag {
            maxMag = magnitudes[i]
            maxIndex = vDSP_Length(i)
        }
    }
    vDSP_destroy_fftsetup(fftSetup)
    let bin = Double(maxIndex)
    let freq = bin * Double(sampleRate) / Double(frameLength)
    return freq
}
}
