//
//  ViewController.swift
//  Ej6CurrentPodometerData
//
//  Created by lucas on 23/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion
class ViewController: UIViewController {
    
    var contando = false
    let pedometer = CMPedometer()

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stepsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func StartButton(_ sender: Any) {
        
        if contando == false {
            contando = true
            self.stepsLabel.textColor = UIColor.black
            self.stepsLabel.text = "0"
            self.startButton.setTitle("FINALIZAR", for: .normal)
            pedometer.startUpdates(from: Date()) { (data, error) in
                DispatchQueue.main.async {
                    self.stepsLabel.text = data?.numberOfSteps.stringValue
                }
            }
            
        } else {
            contando = false
            pedometer.stopUpdates()
            self.startButton.setTitle("EMPEZAR", for: .normal)
            self.stepsLabel.textColor = UIColor.red
            
        }
        
        
        
    }
    
}

