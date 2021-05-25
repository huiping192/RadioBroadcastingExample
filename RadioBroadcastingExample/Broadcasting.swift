//
//  Broadcasting.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import Foundation
import AVFoundation
import HaishinKit

class Broadcasting {
  var audioDataSource: AudioDataSource!
  var videoDataSource: ImageDataSource!

  var rtmpStream: RTMPStream!
  
  init() {
    
    setupRTMP()
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

    rtmpConnection.connect("rtmp://localhost/appName/instanceName")
    rtmpStream.publish("streamName")
    
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
