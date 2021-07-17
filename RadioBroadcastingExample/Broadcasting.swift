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
  
  var fps = 30 {
    didSet {
      imageCaptureSession?.frameInterval = fps // 2fps
    }
  }
  private let maxKeyFrameIntervalDuration = 2 // 2s
  
  private let url: String
  private let key: String
  
  private var rtmpStream: RTMPStream!
  private var imageCaptureSession: ImageCaptureSession?
  
  var image: UIImage? {
    didSet {
      guard let image = image else { return }
      imageCaptureSession?.image = image
    }
  }
  
  private var sender: RadioImageBufferSender?
  
  init(url: String, key: String) {
    self.url = url
    self.key = key
    
    setupAudioSession()
    setupRTMP()
  }
  
  func start() {
    rtmpStream.publish(key)
    
    sender?.start()
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
    self.rtmpStream = RTMPStream(connection: rtmpConnection)
    rtmpStream.audioSettings = [
        .muted: true, // mute audio
        .bitrate: 32 * 1000,
    ]
    self.image = UIImage(named: "test")!
    let size = image!.size
    rtmpStream.videoSettings = [
      .width: size.width, // video output width
      .height: size.height, // video output height
        .bitrate: 750 * 1000, // video output bitrate
        .profileLevel: kVTProfileLevel_H264_Main_3_0,
        .maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration, // key frame / sec
    ]
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
        fatalError("attachAudio failed!")
    }
    
    // only support foreground broadcast
//    setupForegroundBroadcast()
    
    setupBackgroundSupport()
            
    rtmpConnection.connect(url)
  }
  
  func setupForegroundBroadcast() {
     self.imageCaptureSession = ImageCaptureSession(image: image!, frameInterval: fps)
     rtmpStream.attachScreen(imageCaptureSession)
  }
  
  func setupBackgroundSupport() {
    sender = RadioImageBufferSender(image: image!, frameInterval: fps)
    sender?.block =  { sb,time in
      self.rtmpStream.test(buffer: sb, timestamp: time)
    }
    
    sender?.prepare()
    
  }
}
