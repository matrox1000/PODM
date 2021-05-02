//
//  ViewController.swift
//  Ej2iOSBeaconEmitter
//
//  Created by lucas on 05/05/2020.
//  Copyright © 2020 lucas. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController {
    
    var peripheralManager = CBPeripheralManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func createBeaconRegion() -> CLBeaconRegion? {
        let proximityUUID = UUID(uuidString:
                    "39ED98FF-2900-441A-802F-9C398FC199D2")
        let major : CLBeaconMajorValue = 99
        let minor : CLBeaconMinorValue = 1
        let beaconID = "com.example.myDeviceRegion"
            
        return CLBeaconRegion(uuid: proximityUUID!,
                    major: major, minor: minor, identifier: beaconID)
    }


    
}
extension ViewController: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
       
       if (peripheral.state == .poweredOn){
           if (peripheralManager.isAdvertising) {
               peripheralManager.stopAdvertising()
           }
        let region = createBeaconRegion()!
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
            
        peripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        
            
           
          
       }
   }

}
