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
  
  private let fps = 2
  private let maxKeyFrameIntervalDuration = 2 // 2s
  
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
    let image = UIImage(named: "test")!
    let size = image.size
    rtmpStream.videoSettings = [
      .width: size.width, // video output width
      .height: size.height, // video output height
        .bitrate: 750 * 1000, // video output bitrate
        .profileLevel: kVTProfileLevel_H264_Main_3_0,
        .maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration, // key frame / sec
    ]
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
        // print(error)
    }
    let imageCaptureSession = ImageCaptureSession(image: image, frameInterval: fps)
    imageCaptureSession.frameInterval = fps // 2fps
    rtmpStream.attachScreen(imageCaptureSession)

    rtmpConnection.connect("rtmp://a.rtmp.youtube.com/live2")
    
    self.rtmpStream = rtmpStream
  }
}
