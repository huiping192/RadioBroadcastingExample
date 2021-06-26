//
//  RadioImageBufferSender.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/07/14.
//

import Foundation
import UIKit
import HaishinKit
import AVFoundation

class RadioImageBufferSender {
  private let lockQueue = DispatchQueue(
    label: "com.haishinkit.HaishinKit.ImageCaptureSession.lock", qos: .userInteractive, attributes: []
  )
  let encoder: RadioImageEncoder
  
  private var displayLink: CADisplayLink!
  public var frameInterval: Int = ImageCaptureSession.defaultFrameInterval {
    didSet {
      self.displayLink.preferredFramesPerSecond = frameInterval
    }
  }
  
  public var isRunning: Bool {
    return !displayLink.isPaused
  }

  var block: ((CMSampleBuffer)->Void)?
  
  private var index: Int = 0
  
  public init(image: UIImage, frameInterval: Int) {
    encoder = RadioImageEncoder(image: image, frameInterval: frameInterval)
    
    self.displayLink = CADisplayLink(target: self, selector: #selector(onScreen))
    self.displayLink.preferredFramesPerSecond = frameInterval
    self.displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    self.displayLink.isPaused = true
  }
  
  public func prepare() {
    encoder.encode()
  }
  
  public func start() {
    lockQueue.sync {
      index = 0
      self.displayLink.isPaused = false
    }
  }
  
  public func stop() {
    lockQueue.sync {
      self.displayLink.isPaused = true
    }
  }
  
  @objc
  public func onScreen(_ displayLink: CADisplayLink) {
    lockQueue.async {
      autoreleasepool {
        self.onScreenProcess(displayLink)
      }
    }
  }
  
  func onScreenProcess(_ displayLink: CADisplayLink) {
    let sb = encoder.sampleBuffers[index]
    
    CMSampleBufferSetOutputPresentationTimeStamp(sb,newValue: CMTimeMakeWithSeconds(displayLink.timestamp, preferredTimescale: 1000))
    
    index += 1
    if index == frameInterval {
      index = 0
    }
    block?(sb)
  }
}


