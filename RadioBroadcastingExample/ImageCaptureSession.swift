//
//  ImageCaptureSession.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/06/02.
//

import Foundation
import HaishinKit
import AVFoundation

class ImageCaptureSession: NSObject, CustomCaptureSession {
  static let defaultFrameInterval: Int = 30
  static let defaultAttributes: [NSString: NSObject] = [
    kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_32BGRA),
    kCVPixelBufferCGBitmapContextCompatibilityKey: true as NSObject
  ]
  
  public var enabledScale = false
  public var frameInterval: Int = ImageCaptureSession.defaultFrameInterval {
    didSet {
      self.displayLink.preferredFramesPerSecond = frameInterval
    }
  }
  public var attributes: [NSString: NSObject] {
    var attributes: [NSString: NSObject] = ImageCaptureSession.defaultAttributes
    attributes[kCVPixelBufferWidthKey] = NSNumber(value: Float(size.width * scale))
    attributes[kCVPixelBufferHeightKey] = NSNumber(value: Float(size.height * scale))
    attributes[kCVPixelBufferBytesPerRowAlignmentKey] = NSNumber(value: Float(size.width * scale * 4))
    return attributes
  }
  public weak var delegate: ScreenCaptureOutputPixelBufferDelegate?
  public internal(set) var isRunning: Atomic<Bool> = .init(false)
  
  private var context = CIContext(options: [.useSoftwareRenderer: NSNumber(value: false)])
  
  public var afterScreenUpdates = false
  private let semaphore = DispatchSemaphore(value: 1)
  private let lockQueue = DispatchQueue(
    label: "com.haishinkit.HaishinKit.ImageCaptureSession.lock", qos: .userInteractive, attributes: []
  )
  private var colorSpace: CGColorSpace!
  private var displayLink: CADisplayLink!
  
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

  private var size: CGSize = .zero {
    didSet {
      guard size != oldValue else {
        return
      }
      delegate?.didSet(size: CGSize(width: size.width * scale, height: size.height * scale))
      pixelBufferPool = nil
    }
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
  
  private var pixelBuffer: CVPixelBuffer?
  
  public init(image: UIImage, frameInterval: Int) {
    self.image = image
    self.size = image.size
    self.frameInterval = frameInterval

    super.init()
  }
  
  @objc
  public func onScreen(_ displayLink: CADisplayLink) {
    guard semaphore.wait(timeout: .now()) == .success else {
      return
    }
    
    size = image.size
    
    lockQueue.async {
      autoreleasepool {
        self.onScreenProcess(displayLink)
      }
      self.semaphore.signal()
    }
  }
  
  open func onScreenProcess(_ displayLink: CADisplayLink) {
    
    delegate?.output(pixelBuffer: self.pixelBuffer!, withPresentationTime: CMTimeMakeWithSeconds(displayLink.timestamp, preferredTimescale: 1000))
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, [])
  }
}

extension ImageCaptureSession: Running {
  // MARK: Running
  public func startRunning() {
    lockQueue.sync {
      guard !self.isRunning.value else {
        return
      }
      self.isRunning.mutate { $0 = true }
      self.pixelBufferPool = nil
      self.colorSpace = CGColorSpaceCreateDeviceRGB()
      self.displayLink = CADisplayLink(target: self, selector: #selector(onScreen))
      self.displayLink.preferredFramesPerSecond = frameInterval
      self.displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
  }
  
  public func stopRunning() {
    lockQueue.sync {
      guard self.isRunning.value else {
        return
      }
      self.displayLink.remove(from: .main, forMode: RunLoop.Mode.common)
      self.displayLink.invalidate()
      self.colorSpace = nil
      self.displayLink = nil
      self.isRunning.mutate { $0 = false }
    }
  }
}
