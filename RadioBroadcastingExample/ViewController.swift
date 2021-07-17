//
//  ViewController.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import UIKit
import AVFoundation

class ViewController: UITableViewController {
  
  private var picker = UIImagePickerController()
  
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var fpsText: UITextField!

  var broadCasting: Broadcasting?
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    broadCasting = Broadcasting(url: "rtmp://a.rtmp.youtube.com/live2", key: "")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  @IBAction func imagePickUpButtonClicked(_: UIButton){
    picker.sourceType = UIImagePickerController.SourceType.photoLibrary
    picker.delegate = self
    picker.navigationBar.tintColor = UIColor.white
    picker.navigationBar.barTintColor = UIColor.gray
    
    present(picker, animated: true, completion: nil)
  }
  
  private func updateImage(image: UIImage) {
    imageView.image = image
  }
  
  @IBAction func startButtonClicked() {
//    broadCasting?.image = imageView.image
//    broadCasting?.fps = Int(fpsText.text ?? "30") ?? 30

    broadCasting?.start()
  }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
      updateImage(image: image)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
}
