//
//  ViewController.swift
//  Ej4NeedleDown
//
//  Created by lucas on 21/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion



class ViewController: UIViewController {
    let motionManager = CMMotionManager()
    @IBOutlet weak var needleUIImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
                // https://www.raywenderlich.com/5504-trigonometry-for-game-programming-spritekit-and-swift-tutorial-part-1-2
                let radians = atan2(( motion?.gravity.y)!,( motion?.gravity.x)!) + ( .pi / 2.0)
                self.needleUIImage.transform = CGAffineTransform(rotationAngle: CGFloat(radians * (-1.0)))
                
            }
        }
    }


}

