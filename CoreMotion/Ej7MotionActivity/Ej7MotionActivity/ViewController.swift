//
//  ViewController.swift
//  Ej7MotionActivity
//
//  Created by lucas on 23/01/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var stationaryLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var automotiveLabel: UILabel!
    @IBOutlet weak var cyclingLabel: UILabel!
    @IBOutlet weak var unknownLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let motionActivityManager = CMMotionActivityManager()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                self.stationaryLabel.text = (motion?.stationary)! ? "True" : "False"
                self.walkingLabel.text = (motion?.walking)! ? "True" : "False"
                self.runningLabel.text = (motion?.running)! ? "True" : "False"
                self.automotiveLabel.text = (motion?.automotive)! ? "True" : "False"
                self.cyclingLabel.text = (motion?.cycling)! ? "True" : "False"
                self.unknownLabel.text = (motion?.unknown)! ? "True" : "False"
                
                self.startDateLabel.text = dateFormatter.string(from: (motion?.startDate)!)
                

                if motion?.confidence == CMMotionActivityConfidence.low {
                    self.confidenceLabel.text = "Low"
                } else if motion?.confidence == CMMotionActivityConfidence.medium {
                    self.confidenceLabel.text = "Good"
                } else if motion?.confidence == CMMotionActivityConfidence.high {
                    self.confidenceLabel.text = "High"
                }
            }
            
            let calendar = Calendar.current
            motionActivityManager.queryActivityStarting(from: calendar.startOfDay(for: Date()) - 86400, to: Date(), to: OperationQueue.main) { (motionActivities, error) in
                var timeAutomotive = TimeInterval()
                var prevAuto = false
                var prevTime = Date()
                for motionActivity in motionActivities! {
                    if motionActivity.confidence == .medium || motionActivity.confidence == .high {
                        

                        if motionActivity.automotive {
                            if prevAuto {
                                timeAutomotive = timeAutomotive + ( motionActivity.startDate.timeIntervalSinceReferenceDate - prevTime.timeIntervalSinceReferenceDate)
                            }
                            print(motionActivity)
                            prevAuto = true
                            prevTime = motionActivity.startDate
                        } else {
                            if prevAuto {
                                print(motionActivity)
                                prevAuto = false
                                timeAutomotive = timeAutomotive + ( motionActivity.startDate.timeIntervalSinceReferenceDate - prevTime.timeIntervalSinceReferenceDate)
                            }
                        }
                    }
                } // for
                if prevAuto{
                    timeAutomotive = timeAutomotive + ( Date().timeIntervalSinceReferenceDate - prevTime.timeIntervalSinceReferenceDate)
                    
                }
                
                print (timeAutomotive / 60.0)
            } //closure
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
