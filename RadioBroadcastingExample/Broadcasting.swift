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
  var dataSource: BroadcastingDataSource!
  var rtmpStream: RTMPStream!
  
  init() {
    
    setupRTMP()
  }
  
  func setupDataSource() {
    let dataSource = BroadcastingDataSource()
    dataSource.delegate = self
    
    self.dataSource = dataSource
  }
  
  func setupRTMP() {
    let rtmpConnection = RTMPConnection()
    let rtmpStream = RTMPStream(connection: rtmpConnection)
    rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
        // print(error)
    }
    rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
        // print(error)
    }

    rtmpConnection.connect("rtmp://localhost/appName/instanceName")
    rtmpStream.publish("streamName")
    
    self.rtmpStream = rtmpStream
  }
}

extension Broadcasting: BroadcastingDataSourceDelegate {
  func videoSource(_ broadcastingDataSource: BroadcastingDataSource, didOutput sampleBuffer: CMSampleBuffer) {
    rtmpStream.appendSampleBuffer(sampleBuffer, withType: .audio)
  }

}
