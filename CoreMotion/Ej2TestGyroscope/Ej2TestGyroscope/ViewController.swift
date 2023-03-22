//
//  ViewController.swift
//  Ej2TestGyroscope
//
//  Created by lucas on 19/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if motionManager.isGyroAvailable {
            
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { (data, error) in
                print(data ?? "data es null")
            }
            
        } else
        {
            print ("Giroscopio no disponible")
        }
        
        
    }
    
    
}
