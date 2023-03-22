//
//  ViewController.swift
//  Ej5Pedometer
//
//  Created by lucas on 23/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let pedometer = CMPedometer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if CMPedometer.isStepCountingAvailable() {
            let calendar = Calendar.current
            pedometer.queryPedometerData(from: calendar.startOfDay(for: Date()), to: Date()) { (data, error) in
                print(data ?? "Dato no disponible")
            }
        }
    }


}

