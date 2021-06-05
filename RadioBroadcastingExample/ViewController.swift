//
//  ViewController.swift
//  RadioBroadcastingExample
//
//  Created by Huiping Guo on 2021/05/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var broadCasting: Broadcasting?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
      broadCasting = Broadcasting(url: "rtmp://a.rtmp.youtube.com/live2", key: "")
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    broadCasting?.start()
  }


}

