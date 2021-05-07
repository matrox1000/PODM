//
//  ViewController.swift
//  P2CompBleInvadersV2
//
//  Created by lucas on 2/5/21.
//

import Cocoa
import AVFoundation
import CoreBluetooth

class ViewController: NSViewController {
    
    @IBOutlet var window: NSView!
    
    //BLE
    
    let SERVICE_UUID_XY = CBUUID(string: "0BE27C50-8BD0-40A5-AC61-88DC52CE9C64")
    let SERVICE_UUID_SHOOT = CBUUID(string: "5DA21B79-CA3E-4398-A470-4565E6D02A61")
    let CHARACTERISTIC_UUID_SHOOT = CBUUID(string: "8113F397-0840-4BDB-B9C6-DFD6BE7A7172")
    
    let CHARACTERISTIC_UUID_X = CBUUID(string:"C1B89437-74B3-4DA7-9780-9EDAC73CD146")
    let CHARACTERISTIC_UUID_Y = CBUUID(string:"08D12BDA-CAE0-424B-B9F6-478C13CC400B")
    
    let CHARACTERISTIC_PROPERTIES: CBCharacteristicProperties = .read
    let CHARACTERISTIC_PERMISSIONS: CBAttributePermissions = .readable
    
    let CHARACTERISTIC_PROPERTIES_SHOOT: CBCharacteristicProperties = .writeWithoutResponse
    let CHARACTERISTIC_PERMISSIONS_SHOOT: CBAttributePermissions = .writeable
    
    let namePeripherical = "Soy el periférico:"
    
    
    
    var selectedPeripheral : CBPeripheral!
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    
    //GAME
    let aimImageView = NSImageView(image: NSImage(named: "aim")!)
    let fireImageView = NSImageView(image: NSImage(named: "fire")!)
    var targets = [NSImageView]()
    var currentTarget = 0
    
    let numberOfSmoothUpdates = 25
    var eyeGazeHistory = ArraySlice<CGPoint>()
    
    let targetNames = ["alien-blue", "alien-red", "alien-green", "alien-orange"]
    
    var laserShot: AVAudioPlayer?
    
    var startTime = CACurrentMediaTime()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        // change the background color of the layer
        view.layer?.backgroundColor = NSColor.white.cgColor
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        aimImageView.frame = CGRect(x:self.view.bounds.midX, y:self.view.bounds.midY, width:64, height:64)
        fireImageView.frame = CGRect(x:self.view.bounds.midX, y:self.view.bounds.midY, width:64, height:64)
        initializeTargets()
        perform(#selector(createTarget), with: nil, afterDelay: 3.0)
    }
    
    
    
    func initializeTargets(){
        //crea una NSStackView de marcianos por código
        let rowStackView = NSStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        rowStackView.distribution = .fillEqually
        rowStackView.orientation = .vertical
        rowStackView.spacing = 20
        
        for _ in 1...8 {
            let colStackView = NSStackView()
            //colStackView.translatesAutoresizingMaskIntoConstraints = false
            
            colStackView.distribution = .fillEqually
            //colStackView.axis = .horizontal
            colStackView.spacing = 20
            
            rowStackView.addArrangedSubview(colStackView)
            
            for imageName in targetNames {
                let imageView = NSImageView(image: NSImage(named:imageName)!)
                imageView.layerContentsPlacement = .scaleProportionallyToFill
                imageView.alphaValue = 0
                targets.append(imageView)
                
                colStackView.addArrangedSubview(imageView)
            }
        }
        
        self.view.addSubview(rowStackView)
        
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            rowStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
            
            ])
        
        self.view.addSubview(aimImageView)
        fireImageView.alphaValue=0.0
        self.view.addSubview(fireImageView)
        targets.shuffle()
    }
    
    @objc func createTarget(){
        
        guard currentTarget < self.targets.count else {
            endGame()
            return
        }
        //Objetivo actual que queremos mostrar por pantalla
        let target = self.targets[currentTarget]

        
        NSAnimationContext.runAnimationGroup({context in
          context.duration = 0.5
          context.allowsImplicitAnimation = true
            target.alphaValue = 1.0
            self.fireImageView.alphaValue = 0.0
            self.view.layoutSubtreeIfNeeded()

        }, completionHandler:nil)
        currentTarget += 1
        self.fireImageView.alphaValue = 0.0
    }
    
    func shoot(){
        if let url = Bundle.main.url(forResource: "laser-sound", withExtension: "wav") {
            laserShot = try? AVAudioPlayer(contentsOf: url)
            laserShot?.play()
        }
        let aimFrame = aimImageView.superview!.convert(aimImageView.frame, to: nil)
        
        print ("disparo recibido")
        let hitTargets = self.targets.filter { iv -> Bool in
            if iv.alphaValue == 0 { return false }
            let targetFrame = iv.superview!.convert(iv.frame, to: nil)
            print ("acierto: \(targetFrame.intersects(aimFrame))")
            return targetFrame.intersects(aimFrame)
        }
        
        guard let selectedTarget = hitTargets.first else {
            return
        }
        
        self.fireImageView.frame.origin = CGPoint(x:Double(self.aimImageView.frame.origin.x) , y: Double(self.aimImageView.frame.origin.y))
        //self.fireImageView.frame.origin=self.aimImageView.frame.origin
        fireImageView.alphaValue = 1.0
        
        
        /*
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 1.5
            fireImageView.alphaValue = 0.0
            //self.fireImageView.animator().isHidden = true
            self.view.layoutSubtreeIfNeeded()

        }, completionHandler: {
            print ("animacion completada")
            //self.fireImageView.alphaValue = 0.0
        })
        
        */

        
        selectedTarget.alphaValue = 0
        
        if let url = Bundle.main.url(forResource: "explosion", withExtension: "wav") {
            laserShot = try? AVAudioPlayer(contentsOf: url)
            laserShot?.play()
        }
        
        perform(#selector(createTarget), with: nil, afterDelay: 1.5)
    }

    
    
    func endGame(){
        let gameTime = Int(CACurrentMediaTime() - startTime)
        
        let alert = NSAlert()
        alert.messageText = "Fin de la partida"
        alert.informativeText = "Has tardado \(gameTime) segundos."
        alert.runModal()
        perform(#selector(backToMainMenu), with: nil, afterDelay: 4.0)
    }
    
    @objc func backToMainMenu(){
        /*dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }*/
        print ("end game")
    }

}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [SERVICE_UUID_XY], options: nil)
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
        
        
        selectedPeripheral.discoverServices([SERVICE_UUID_XY])
        print ("Central: hemos conectado con el periférico:" + peripheral.name!)
        
    }
}


extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            print ("Central: hemos encontrado un servicio con UUID: " + service.uuid.uuidString)
            
            if service.uuid == SERVICE_UUID_XY {
                
                
                peripheral.discoverCharacteristics([CHARACTERISTIC_UUID_X,CHARACTERISTIC_UUID_Y], for: service)
                print ("Central: hemos encontrado el servicio y procedemos a descubrir características")
                
                
                
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("Central: Hemos encontrado caracterísitca con UUID: " + characteristic.uuid.uuidString + " del periférico:" + characteristic.service.peripheral.name!)
            
            if (characteristic.uuid == CHARACTERISTIC_UUID_Y || characteristic.uuid == CHARACTERISTIC_UUID_X)  {
                if (characteristic.properties.contains(.notify)){
                    print("Central: Hemos encontrado caracterísitca Y o X y solicitamos lectura de su valor")
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
        
        if characteristic.uuid == CHARACTERISTIC_UUID_Y {
            
            if let value = characteristic.value {
                
                let stringValue = String(data: value, encoding: String.Encoding.utf8) ?? "0.0"
                //print (Double(stringValue))
               
                let intValue = ((Double(stringValue) ?? 0) * Double(self.view.bounds.midY) * (-1.0))+Double(self.view.bounds.midY)
            
                 //print ("Central: hemos conseguido leer el valor para Y: \(intValue)")
                
                self.aimImageView.frame.origin = CGPoint(x:Double(self.aimImageView.frame.origin.x) , y: intValue)
                
                
            }
             } // END if characteristic.uuid ==...
            
            if characteristic.uuid == CHARACTERISTIC_UUID_X {
            
            if let value = characteristic.value {
                
                let stringValue = String(data: value, encoding: String.Encoding.utf8) ?? "0.0"
                //print (Double(stringValue))
               
                let intValue = ((Double(stringValue) ?? 0) * Double(self.view.bounds.midX) * (-1.0))+Double(self.view.bounds.midX)
            
                 //print ("Central: hemos conseguido leer el valor para X: \(intValue)")
                
                self.aimImageView.frame.origin = CGPoint(x:intValue , y: Double(self.aimImageView.frame.origin.y))
                
                
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
            let myService = CBMutableService(type: SERVICE_UUID_SHOOT, primary: true)
            let myCharacteristic = CBMutableCharacteristic(type: CHARACTERISTIC_UUID_SHOOT, properties: CHARACTERISTIC_PROPERTIES_SHOOT, value: nil, permissions: CHARACTERISTIC_PERMISSIONS_SHOOT)
            myService.characteristics = [myCharacteristic]
            
            //La añadimos al periférico local
            peripheralManager.add(myService)
            print("Periférico: Inicializamos arbol de servicios y características")
            
            
            
            
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID_SHOOT], CBAdvertisementDataLocalNameKey: namePeripherical])
            
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
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print ("recibimos disparo")
        shoot()
    }
    
    
    
}

