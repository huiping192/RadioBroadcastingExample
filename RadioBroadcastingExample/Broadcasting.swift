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
  var dataSource: AudioDataSource!
  var rtmpStream: RTMPStream!
  
  init() {
    
    setupRTMP()
  }
  
  func setupDataSource() {
    let dataSource = AudioDataSource()
    dataSource.delegate = self
    
    self.dataSource = dataSource
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
