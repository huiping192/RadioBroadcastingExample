//
//  BroadcastingDataSource.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import Foundation
import AVFoundation

protocol AudioDataSourceDelegate: class {
  func audioDataSource(_ audioDataSource: AudioDataSource, didOutput sampleBuffer: CMSampleBuffer)
}

class AudioDataSource: NSObject {
  
  let captureSession = AVCaptureSession()
  
  weak var delegate: AudioDataSourceDelegate?
  
  private var session: AVAudioSession = .sharedInstance()
  
  private let taskQueue = DispatchQueue(label: "com.huiping192.Radio.RadioBroadcastingExample.audioCapture")
  
  override init() {
    super.init()
    
    configureAudioSession()
    configureAudio()
  }
  
  func configureAudioSession() {
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
  
  private func configureAudio() {
    guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
      fatalError("Can not found audio device!")
    }
    guard let audioDeviceInput = try? AVCaptureDeviceInput.init(device: audioDevice) else {
      fatalError("Init audio CaptureDeviceInput failed!")
    }
    
    if captureSession.canAddInput(audioDeviceInput) {
      captureSession.addInput(audioDeviceInput)
    }
    
    let audioOutput = AVCaptureAudioDataOutput()
    audioOutput.setSampleBufferDelegate(self, queue: taskQueue)
    
    if captureSession.canAddOutput(audioOutput) {
      captureSession.addOutput(audioOutput)
    }
  }
}


extension AudioDataSource: AVCaptureAudioDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
  
    delegate?.audioDataSource(self, didOutput: sampleBuffer)
  }
}
