//
//  RadioImageEncoder.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/06/27.
//

import Foundation
import HaishinKit
import AVFoundation

class RadioImageEncoder {
  
  lazy var encoder = H264Encoder()

  public var attributes: [NSString: NSObject] {
    var attributes: [NSString: NSObject] = ImageCaptureSession.defaultAttributes
    attributes[kCVPixelBufferWidthKey] = NSNumber(value: Float(size.width * scale))
    attributes[kCVPixelBufferHeightKey] = NSNumber(value: Float(size.height * scale))
    attributes[kCVPixelBufferBytesPerRowAlignmentKey] = NSNumber(value: Float(size.width * scale * 4))
    return attributes
  }
  
  private var scale: CGFloat {
    1.0
  }
  
  private var _pixelBufferPool: CVPixelBufferPool?
  private var pixelBufferPool: CVPixelBufferPool! {
    get {
      if _pixelBufferPool == nil {
        var pixelBufferPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary?, &pixelBufferPool)
        _pixelBufferPool = pixelBufferPool
      }
      return _pixelBufferPool!
    }
    set {
      _pixelBufferPool = newValue
    }
  }
  
  private var context = CIContext(options: [.useSoftwareRenderer: NSNumber(value: false)])

  private var pixelBuffer: CVPixelBuffer?
  
  var sampleBuffers: [CMSampleBuffer] = []
  
  private var size: CGSize = .zero
  
  var image: UIImage {
    didSet {
      var pixelBuffer: CVPixelBuffer?
      
      let cgimage = image.cgImage!
      CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
      CVPixelBufferLockBaseAddress(pixelBuffer!, [])
      context.render(CIImage(cgImage: cgimage), to: pixelBuffer!)
      self.pixelBuffer = pixelBuffer
      
      size = image.size
    }
  }
  
  public var frameInterval: Int = ImageCaptureSession.defaultFrameInterval
    
  public init(image: UIImage, frameInterval: Int) {
    self.image = image
    self.size = image.size
    self.frameInterval = frameInterval
    
    encoder.delegate = self
  }
  
  public func encode() {
    guard let pixelBuffer = pixelBuffer else { return }

    // 1gopをエンコードする
    (0..<frameInterval).forEach { i in
      self.encoder.encodeImageBuffer(pixelBuffer, presentationTimeStamp: CMTimeMakeWithSeconds(Float64(i), preferredTimescale: 1000), duration: CMTime.invalid)
    }
  }
}


extension RadioImageEncoder: VideoEncoderDelegate {
  func didSetFormatDescription(video formatDescription: CMFormatDescription?) {
    
  }
  func sampleOutput(video sampleBuffer: CMSampleBuffer) {
    self.sampleBuffers.append(sampleBuffer)
  }
}
