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
  var audioDataSource: AudioDataSource!
  var videoDataSource: ImageDataSource!

  var rtmpStream: RTMPStream!
  
  init() {
    
    setupRTMP()
  }
  
  func start() {
    setupDataSource()
    
    audioDataSource.start()
    videoDataSource.start()
  }
  
  func setupDataSource() {
    let audioDataSource = AudioDataSource()
    audioDataSource.delegate = self

    self.audioDataSource = audioDataSource
    
    let image = UIImage(named: "test")!
    let videoDataSource = ImageDataSource(image: image, fps: 30)
    videoDataSource.delegate = self
    
    self.videoDataSource = videoDataSource
  }
  
  func setupRTMP() {
    let rtmpConnection = RTMPConnection()
    let rtmpStream = RTMPStream(connection: rtmpConnection)
    rtmpStream.audioSettings = [
        .muted: true, // mute audio
        .bitrate: 32 * 1000,
    ]
    rtmpStream.videoSettings = [
        .width: 360, // video output width
        .height: 640, // video output height
        .bitrate: 750 * 1000, // video output bitrate
        .profileLevel: kVTProfileLevel_H264_Baseline_3_1, // H264 Profile require "import VideoToolbox"
        .maxKeyFrameIntervalDuration: 2, // key frame / sec
    ]
    
//    rtmpStream.attachScreen(ScreenCaptureSession(shared: UIApplication.shared))

    rtmpConnection.connect("rtmp://a.rtmp.youtube.com/live2")
    rtmpStream.publish("")
    
    
    self.rtmpStream = rtmpStream
  }
}

extension Broadcasting: AudioDataSourceDelegate {
  func audioDataSource(_ audioDataSource: AudioDataSource, didOutput sampleBuffer: CMSampleBuffer) {
    rtmpStream.appendSampleBuffer(sampleBuffer, withType: .audio)
  }
}

extension Broadcasting: ImageDataSourceDelegate {
  func imageDataSource(_ imageDataSource: ImageDataSource, didOutput sampleBuffer: CMSampleBuffer){
    rtmpStream.appendSampleBuffer(sampleBuffer, withType: .video)
  }
  
}
