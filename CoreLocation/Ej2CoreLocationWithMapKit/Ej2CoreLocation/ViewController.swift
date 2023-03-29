//
//  ViewController.swift
//  Ej1CoreLocation
//
//  Created by lucas on 15/02/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit

import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    

    private let locationManager = CLLocationManager()
    private var locationsHistory: [CLLocation] = []
    private var totalMovementDistance = CLLocationDistance(0)
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var horizontalAccuracyLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var verticalAccuracyLabel: UILabel!
    @IBOutlet var distanceTraveledLabel: UILabel!
    @IBOutlet var mapView:MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.userTrackingMode = .follow
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        

        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("Empezamos a sondear la ubicación")
            mapView.showsUserLocation = true
        default:
            locationManager.stopUpdatingLocation()
            print("Paramos el sondeo de la ubicación")
            mapView.showsUserLocation = false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Location Manager Error", message: error.localizedDescription , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation]) {
        
        if let location = locations.last{
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
        
        
        for newLocation in locations {
            if newLocation.horizontalAccuracy < 100 && newLocation.horizontalAccuracy >= 0 && newLocation.verticalAccuracy < 50 {
                let latitudeString = String(format: "%gº", newLocation.coordinate.latitude)
                latitudeLabel.text = latitudeString
                let longitudeString = String(format: "%gº", newLocation.coordinate.longitude)
                longitudeLabel.text = longitudeString
                let horizontalAccuracyString = String(format:"%gm", newLocation.horizontalAccuracy)
                horizontalAccuracyLabel.text = horizontalAccuracyString
                let altitudeString = String(format:"%gm", newLocation.altitude)
                altitudeLabel.text = altitudeString
                let verticalAccuracyString = String(format:"%gm", newLocation.verticalAccuracy)
                verticalAccuracyLabel.text = verticalAccuracyString
                if let previousPoint = locationsHistory.last {
                    print("movement distance: " + "\(newLocation.distance(from: previousPoint))")
                    totalMovementDistance += newLocation.distance(from: previousPoint)
                    
                    var area = [previousPoint.coordinate, newLocation.coordinate]
                    let polyline = MKPolyline(coordinates: &area, count: area.count)
                    mapView.addOverlay(polyline)
                } else
                {
                    let start = Place(title:"Inicio",
                                      subtitle:"Este es el punto de inicio de la ruta",
                                      coordinate:newLocation.coordinate)
                    mapView.addAnnotation(start)
                }
                self.locationsHistory.append(newLocation)
                let distanceString = String(format:"%gm", totalMovementDistance)
                distanceTraveledLabel.text = distanceString
            }
        }
    }
    
    //renderizamos los overlays
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.red
            pr.lineWidth = 5
            return pr
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
    }


}

