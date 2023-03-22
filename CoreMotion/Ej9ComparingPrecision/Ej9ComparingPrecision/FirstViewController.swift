//
//  FirstViewController.swift
//  Ej9ComparingPrecision
//
//  Created by lucas on 20/02/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class FirstViewController: UIViewController {

    @IBOutlet weak var needleUImage: UIImageView!
    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval=0.01
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (motion, error) in
                let radians = atan2(( motion?.acceleration.y)!,( motion?.acceleration.x)!) + ( .pi / 2.0)
                self.needleUImage.transform = CGAffineTransform(rotationAngle: CGFloat(radians * (-1.0)))
                
            }
            
        }
        
    }


}

