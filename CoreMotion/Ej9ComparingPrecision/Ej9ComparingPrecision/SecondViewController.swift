//
//  SecondViewController.swift
//  Ej9ComparingPrecision
//
//  Created by lucas on 20/02/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class SecondViewController: UIViewController {
    
    @IBOutlet weak var needleUImage: UIImageView!
    let motionManager = CMMotionManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval=0.01   
            motionManager.startGyroUpdates(to: OperationQueue.main) { (motion, error) in
                //let radians = atan2(( motion?.rotationRate.y)!,( motion?.rotationRate.x)!) + ( .pi / 2.0)
                self.needleUImage.transform = CGAffineTransform(rotationAngle: CGFloat((motion?.rotationRate.z)!))
                
            }
            
        }
        
    }


}

