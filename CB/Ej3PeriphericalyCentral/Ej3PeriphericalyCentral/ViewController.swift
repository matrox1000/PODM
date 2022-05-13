//
//  ViewController.swift
//  Ej3PeriphericalyCentral
//
//  Created by lucas on 22/03/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import CoreBluetooth




class ViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    let SERVICE_UUID = CBUUID(string: "0BE27C50-8BD0-40A5-AC61-88DC52CE9C64")
    let CHARACTERISTIC_UUID = CBUUID(string: "8113F397-0840-4BDB-B9C6-DFD6BE7A7172")
    let CHARACTERISTIC_PROPERTIES: CBCharacteristicProperties = .read
    let CHARACTERISTIC_PERMISSIONS: CBAttributePermissions = .readable
    let namePeripherical = "Soy el periférico:"
    
    
    
    var selectedPeripheral : CBPeripheral!
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        
       

    }
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
            if (central.state == .poweredOn){
                
                self.centralManager?.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
                print ("Central: empezamos a escanear periféricos")
                
            }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            if advertisementName == namePeripherical{
                centralManager?.stopScan()
                selectedPeripheral = peripheral
                selectedPeripheral.delegate = self
                centralManager?.connect(peripheral)
                print ("Central: paramos de escanear periféricos y conectamos con: " + advertisementName)

            }
        }
    }
        
        
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            
        
        selectedPeripheral.discoverServices([SERVICE_UUID])
        print ("Central: hemos conectado con el periférico:" + peripheral.name!)

    }
}


extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print ("Central: hemos encontrado un servicio con UUID: " + service.uuid.uuidString)
            if service.uuid == SERVICE_UUID {
                peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
                print ("Central: hemos encontrado el servicio y procedemos a descubrir características")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Central: Hemos encontrado caracterísitca con UUID: " + characteristic.uuid.uuidString + " del periférico:" + characteristic.service!.peripheral!.name!)
            if characteristic.uuid == CHARACTERISTIC_UUID {
                if (characteristic.properties.contains(.read)){
                    print("Central: Hemos encontrado caracterísitca y solicitamos lectura de su valor")
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CHARACTERISTIC_UUID {
            if let value = characteristic.value {
                label1.text = String(data: value, encoding: String.Encoding.utf8)!
                print ("Central: hemos conseguido leer el valor: " + String(data: value, encoding: String.Encoding.utf8)!)
            }
        } // END if characteristic.uuid ==...
    } // END func peripheral(... didUpdateValueFor characteristic
}

extension ViewController: CBPeripheralManagerDelegate {
   
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            if (peripheralManager.isAdvertising) {
                peripheralManager.stopAdvertising()
            }
            
            //Montamos servicio y característica
            let myService = CBMutableService(type: SERVICE_UUID, primary: true)
            let message = "Hola, \(UIDevice.current.name)"
            let myCharacteristic = CBMutableCharacteristic(type: CHARACTERISTIC_UUID, properties: CHARACTERISTIC_PROPERTIES, value: message.data(using: .utf8), permissions: CHARACTERISTIC_PERMISSIONS)
            myService.characteristics = [myCharacteristic]
            
            //La añadimos al periférico local
            peripheralManager.add(myService)
            print("Periférico: Inicializamos arbol de servicios y características")
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID], CBAdvertisementDataLocalNameKey: namePeripherical])
            print("Periférico: Empezamos a publicitarnos con el nombre de: " + namePeripherical)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let myError = error {
            print( "Periférico: Error al publicar un servicio:" + myError.localizedDescription)
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let myError = error {
            print( "Periférico: Error al publicitar un servicio:" + myError.localizedDescription)
        }
    }

}


