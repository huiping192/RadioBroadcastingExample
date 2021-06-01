//
//  Broadcasting.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import Foundation
import AVFoundation
import HaishinKit
import VideoToolbox

class Broadcasting {

  var rtmpStream: RTMPStream!
  
  init() {
    setupAudioSession()
    setupRTMP()
  }
  
  func start() {
    rtmpStream.publish("")
  }
  
  
  func setupAudioSession() {
    let session = AVAudioSession.sharedInstance()
    do {
      // https://stackoverflow.com/questions/51010390/avaudiosession-setcategory-swift-4-2-ios-12-play-sound-on-silent
      if #available(iOS 10.0, *) {
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
      } else {
        session.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with: [
                            AVAudioSession.CategoryOptions.allowBluetooth,
                            AVAudioSession.CategoryOptions.defaultToSpeaker]
        )
        try session.setMode(.default)
      }
      try session.setActive(true)
    } catch {
      print(error)
    }
  }
  
  func setupRTMP() {
    let rtmpConnection = RTMPConnection()
    let rtmpStream = RTMPStream(connection: rtmpConnection)
    rtmpStream.audioSettings = [
        .muted: false, // mute audio
        .bitrate: 32 * 1000,
    ]
    rtmpStream.videoSettings = [
        .width: 360, // video output width
        .height: 640, // video output height
        .bitrate: 750 * 1000, // video output bitrate
        .profileLevel: kVTProfileLevel_H264_Baseline_3_1, // H264 Profile require "import VideoToolbox"
        .maxKeyFrameIntervalDuration: 30, // key frame / sec
    ]
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
        // print(error)
    }
    rtmpStream.attachScreen(ImageCaptureSession(image: UIImage(named: "test")!))

    rtmpConnection.connect("rtmp://a.rtmp.youtube.com/live2")
    
    self.rtmpStream = rtmpStream
  }
}
