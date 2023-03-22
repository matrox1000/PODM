//
//  ViewController.swift
//  Ej3TestMagnetometer
//
//  Created by lucas on 21/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.1
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (data, error) in
                print(data ?? "data es null")
            }
        } else
        {
            print ("Magnetómetro no disponible")
        }
    }
    
    
}



