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
  
  var image: UIImage
  
  private var pb: CVPixelBuffer?
  
  init(image: UIImage) {
    self.image = image
    super.init()
    
    setupDisplayLink()
    
    self.pb = image.toCVPixelBuffer()
  }
  
  private func setupDisplayLink() {
    let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(ouput))
    displayLink?.isPaused = pause
    
    displayLink?.preferredFramesPerSecond = Int(30)
    
    displayLink?.add(to: .current, forMode: .default)
    self.displayLink = displayLink
  }
  
  
  @objc private func ouput() {
    autoreleasepool {
      dataQueue.async {
        guard let pb = self.pb else { return }
        let sb = CMSampleBuffer.make(pixelBuffer: pb)

        self.delegate?.imageDataSource(self, didOutput: sb)
      }
    }
    
  }
  
}



