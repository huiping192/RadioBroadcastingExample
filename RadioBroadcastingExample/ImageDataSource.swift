//
//  ImageDataSource.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import Foundation
import AVFoundation
import UIKit

protocol ImageDataSourceDelegate: class {
  func imageDataSource(_ imageDataSource: ImageDataSource, didOutput sampleBuffer: CMSampleBuffer)
}

class ImageDataSource: NSObject {
  
  weak var delegate: ImageDataSourceDelegate?
  
  private let dataQueue = DispatchQueue(label: "com.huiping192.Radio.RadioBroadcastingExample.DataQueue")

  private var displayLink: CADisplayLink?
  private var pause = true {
    didSet {
      displayLink?.isPaused = pause
    }
  }
  
  let image: UIImage
  let fps: Int
  private var pb: CVPixelBuffer?
  
  init(image: UIImage, fps: Int) {
    self.image = image
    self.fps = fps
    
    super.init()
    
    setupDisplayLink()
    
    self.pb = image.toCVPixelBuffer()
  }
  
  func start() {
    pause = false
  }
  
  private func setupDisplayLink() {
    let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
    displayLink?.isPaused = pause
    
    displayLink?.preferredFramesPerSecond = fps
    
    displayLink?.add(to: .current, forMode: .default)
    self.displayLink = displayLink
  }
  
  
  @objc private func ouput() {
    autoreleasepool {
      dataQueue.async {
        let a = CMTimeMakeWithSeconds(self.displayLink!.timestamp, preferredTimescale: 1000)
        guard let pb = self.image.toCVPixelBuffer(), let sb = CMSampleBuffer.make(pixelBuffer: pb, presentationTimeStamp: a) else { return }
        self.delegate?.imageDataSource(self, didOutput: sb)
      }
    }
    
  }
  
}



