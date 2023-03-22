//
//  ThirdViewController.swift
//  Ej9ComparingPrecision
//
//  Created by lucas on 20/02/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ThirdViewController: UIViewController {
    @IBOutlet weak var needleUImage: UIImageView!
    let motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval=0.01
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (motion, error) in
                let radians = atan2(( motion?.magneticField.y)!,( motion?.magneticField.x)!) + ( .pi / 2.0)
                self.needleUImage.transform = CGAffineTransform(rotationAngle: CGFloat(radians * (-1.0)))
                
            }
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
