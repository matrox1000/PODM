//
//  ViewController.swift
//  Ej1Beacons
//
//  Created by lucas on 28/04/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }


}

extension ViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    func startScanning() {
        
        // Encontramos todos los beacons con el UUID específicado
       //let proximityUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        
        let proximityUUID = UUID(uuidString:
                    "39ED98FF-2900-441A-802F-9C398FC199D2")
        //let proximityUUID = UUID(uuidString:"2655be5c-bf96-4e92-9859-2988e71efd01")
        let regionID = "es.ua.mastermoviles.A"
        let majorNumber = CLBeaconMajorValue(99)
        // Creamos la región y empezamos a monitorizarla
        let region = CLBeaconRegion (proximityUUID: proximityUUID!,
                                     major: majorNumber,
                                    identifier: regionID)
        region.notifyEntryStateOnDisplay = true
        self.locationManager.startMonitoring(for: region)
        print("Empezamos a monitorizar región")
        /*
        
         El método didEnterRegion no se ejecutará nunca si no se detecta una entrada en la región. Por tanto, si iniciamos el escaneado estando cerca del beacon simulado, nunca llega a ejecutarse didEnterRegion porque no ha habido un cambio de estar fuera, a estar dentro del alcance del beacon.

         Siguiendo estos pasos, podemos hacer que funcione siempre sin tener que desplazarnos físicamente:

         1. Nos aseguramos de que el simulador de beacon no está transmitiendo.
         2. Comenzamos a escanear.
         3. Esperamos a que se ejecute el evento locationManager(... didDetermineState ...) indicando que estamos fuera de la región.
         4. Ahora iniciamos la transmisión en el simulador.
         5. El escáner detectará la entrada en la región, y comenzar el ranging.
         
        if CLLocationManager.isRangingAvailable() {
            locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
            print("Empezamos a sondear proximidad")

        }
 */
        
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        print ("detectamos región")
        if region is CLBeaconRegion {
            // Empezamos a detectar la proximidad.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                print("Empezamos a sondear proximidad")

            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion {
            // Detenemos la detección de proximidad.
            if CLLocationManager.isRangingAvailable() {
                manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons.first!.proximity)
        } else {
            updateDistance(.unknown)
        }
 
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                
            case .far:
                self.view.backgroundColor = UIColor.blue
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                
            case .immediate:
                self.view.backgroundColor = UIColor.red
            }
        }
    }
}
