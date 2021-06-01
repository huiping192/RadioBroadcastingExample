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
      
      broadCasting = Broadcasting()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    broadCasting?.start()
  }


}

