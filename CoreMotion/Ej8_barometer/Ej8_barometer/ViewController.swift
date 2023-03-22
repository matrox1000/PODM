//
//  ViewController.swift
//  Ej8_barometer
//
//  Created by lucas on 02/02/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    

    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var relativeAltitude: UILabel!
    let altimeter = CMAltimeter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                self.relativeAltitude.text = String.init(format: "%.1fM", (data?.relativeAltitude.floatValue)!)
                self.pressure.text = String.init(format: "%.2f hPA", (data?.pressure.floatValue)!*10)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
