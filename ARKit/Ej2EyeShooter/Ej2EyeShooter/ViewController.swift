//
//  ViewController.swift
//  Ej2EyeShooter
//
//  Created by lucas on 15/04/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    //IBOutlet de la ARSCNView
    @IBOutlet var sceneView: ARSCNView!
    
    
    //Nodo para ubicar la cara
    let face = SCNNode()
    //Creamos el nodo Eye izquerdo
    let leftEye = Eye(color: .green)
    //Creamos el nodo Eye derecho
    let rightEye = Eye(color: .yellow)
    
    //phonePlane será el plano virtual que situaremos sobre la pantalla del iphone. SErá de tamaño 1 metro x 1 metro
    let phonePlane = SCNNode(geometry: SCNPlane(width: 1, height: 1))
    //La UIImageView de la ímagen de francotirador
    let aimImageView = UIImageView(image: UIImage(named: "aim")!)
    
    // El array de marcianos
    var targets = [UIImageView]()
    var currentTarget = 0
    
    //Vamos a utilizar un suavizado para el movimiento de los cilindros. Debido a que la detección de donde está mirando los ojos es muy sensible, el movimiento se realiza muy bruscamente. Utilizaremos un array que irà almacenando el historial de las posiciones para calcular una media y esa será la posición de la mirilla. numberOfSmoothUpdates es el tamaño de dicho historial. Por defecto lo dejamos a 10 pero podemos ajustarlo como consideremos.
    let numberOfSmoothUpdates = 10
    var eyeGazeHistory = ArraySlice<CGPoint>()
    
    //Los tipos de marcianos que tenemos
    let targetNames = ["alien-blue", "alien-red", "alien-green", "alien-orange"]
    // Usaremos un sonido cada vez que matamos a un marciano
    var laserShot: AVAudioPlayer?
    //Nos guardamos el tiempo actual para mostrar al final de la partida el tiempo transcurrido
    var startTime = CACurrentMediaTime()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nos establecemes como delegado del ARSCNView
        sceneView.delegate = self
        //añadimos como hijo del nodo principal el nodo que representará la cara detectada
        sceneView.scene.rootNode.addChildNode(face)
        //Y los ojos serán hijos del nodo que representará la cara detectada
        face.addChildNode(leftEye)
        face.addChildNode(rightEye)
        //añadimos también como hijo del nodo principal el nodo que representará la plano de la pantalla del dispositivo
        sceneView.scene.rootNode.addChildNode(phonePlane)
        
        //En el UIView pintamos centrada en la pantalla la mirilla
        aimImageView.frame = CGRect(x:UIScreen.main.bounds.midX, y:UIScreen.main.bounds.midY, width:64, height:64)
        self.view.addSubview(aimImageView)
        //función que construlle el array y los StackViews de marcianos y los barara. Todos están ocultos al inicio.
        initializeTargets()
        //llamamos a la función que muestra el primer marciano
        perform(#selector(createTarget), with: nil, afterDelay: 3.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Comprobamos si el dispositivo soporta el tracking facial
        guard ARFaceTrackingConfiguration.isSupported else {
            print("No se soporta el tracking de caras...")
            return
        }
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
  
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func initializeTargets(){
        let rowStackView = UIStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        rowStackView.distribution = .fillEqually
        rowStackView.axis = .vertical
        rowStackView.spacing = 20
        
        for _ in 1...8 {
            let colStackView = UIStackView()
            colStackView.translatesAutoresizingMaskIntoConstraints = false
            
            colStackView.distribution = .fillEqually
            colStackView.axis = .horizontal
            colStackView.spacing = 20
            
            rowStackView.addArrangedSubview(colStackView)
            
            for imageName in targetNames {
                let imageView = UIImageView(image: UIImage(named:imageName))
                imageView.contentMode = .scaleAspectFit
                imageView.alpha = 0
                targets.append(imageView)
                
                colStackView.addArrangedSubview(imageView)
            }
        }
        
        self.view.addSubview(rowStackView)
        
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            rowStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
            ])
        
        self.view.bringSubviewToFront(aimImageView)
        
        targets.shuffle()
    }
    
    @objc func createTarget(){
        
        guard currentTarget < self.targets.count else {
            endGame()
            return
        }
        //Objetivo actual que queremos mostrar por pantalla
        let target = self.targets[currentTarget]
        target.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        UIView.animate(withDuration: 0.5) {
            target.transform = .identity
            target.alpha = 1
        }
        currentTarget += 1
    }
    
    func shoot(){
        
        //Convertimos la coordenadas de la posición de la mirilla a las coordenadas base de la ventana: https://developer.apple.com/documentation/uikit/uiview/1622442-convert
        let aimFrame = aimImageView.superview!.convert(aimImageView.frame, to: nil)
        
        //Creamos una esfera para hacer el torpedo y la pintamos de color rojo
        let sphera = SCNSphere(radius: 0.01)
        sphera.firstMaterial?.diffuse.contents = UIColor.red
        //Creamos una array con los dos nodos con la esfera torpedo (uno para cada ojo)
        let fire = [SCNNode(geometry: sphera),SCNNode(geometry: sphera)]
        //Añadimos los nodos torpedos a cada ojo
        leftEye.addChildNode(fire[0])
        rightEye.addChildNode(fire[1])
        for f in fire {
            // los posionamos justo a 7 cm delante del ojo (en la posiciona base de cada objeto Eye
            f.position.z = 0
            // 100% opaco
            f.opacity = 1
            //y ejecutamos una acción de movimiento hasta 1 metro más allá en la dircción z positiva
            f.runAction(SCNAction.moveBy(x: 0, y: 0, z: 1, duration: 3))
            
        }
        //comprobamos si el frame de la mirilla intersecta con el marciano visible mediante un filtro del propio array de marcianos
        let hitTargets = self.targets.filter { iv -> Bool in
            if iv.alpha == 0 { return false }
            let targetFrame = iv.superview!.convert(iv.frame, to: nil)
            
            return targetFrame.intersects(aimFrame)
        }
        
        // Si al menos obtenemos uno lo almacenamos en selectedTarget
        guard let selectedTarget = hitTargets.first else {
            return
        }
        
        //Para luego ocultarlo
        selectedTarget.alpha = 0
        
        //Emitimos el sonido de marciando destruido
        if let url = Bundle.main.url(forResource: "laser-sound", withExtension: "wav") {
            laserShot = try? AVAudioPlayer(contentsOf: url)
            laserShot?.play()
        }
        
        //Y llamamos a createTarget para mostrar otro marciano
        perform(#selector(createTarget), with: nil, afterDelay: 1.5)
    }
    

    
    
func endGame(){
    let gameTime = Int(CACurrentMediaTime() - startTime)
    let alertController = UIAlertController(title: "Fin de la partida", message: "Has tardado \(gameTime) segundos.", preferredStyle: .alert)
    present(alertController, animated: true)
    
    perform(#selector(backToMainMenu), with: nil, afterDelay: 4.0)
}

@objc func backToMainMenu(){
    dismiss(animated: true) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
}

// MARK: - ARSCNViewDelegate

extension ViewController:ARSCNViewDelegate{
        
    
    //Con la configuracion de Face Tracking. Este método se ejecuta cada vez que las propiedades de la cara (El ARFaceAnchor) son actualizadas, es decir, cada vez que se produce un gesto, cambio de posición, etc, y el SCNNode asociado a la cara es actualizado. Lo utilizamos para posicionar el nodo que utilizamos para representar la cara (self.face.) y llamamos al método update donde comprobamos si el usuario guiña los ojos.
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //Nos aseguramos primero que el ARAnchor que se ha actualizado sea el de la cara
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        DispatchQueue.main.async {
            self.face.simdTransform = node.simdTransform
            self.update(using: faceAnchor)
        }
        
    }
        
    
    // Método heredado de SCNSceneRendererDelegate. Cada vez que se va a renderizar un frame se invoca este método. En él obtenemos la posición de la cámara virtual y desplazamos  a la posición de la cámara virtual, el plano de la pantalla del iphone que utilizamos para situar la escena del juego.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView?.simdTransform else { return }
        
        self.phonePlane.simdTransform = pointOfView
    }
    
    
    func update(using anchor: ARFaceAnchor){
        
        if let leftBlink = anchor.blendShapes[.eyeBlinkLeft] as? Float,
            let rightBlink = anchor.blendShapes[.eyeBlinkRight] as? Float {
            //Si tenemos evidencias de que ambos ojos parpaean más de un 40%, disparamos y listo
            if leftBlink > 0.4 && rightBlink > 0.4 {
                shoot()
                return
            }
        }
        
        //Colocamos los cilindros en los ojos
        leftEye.simdTransform = anchor.leftEyeTransform
        rightEye.simdTransform = anchor.rightEyeTransform
        
        let intersectPoints = [leftEye, rightEye].compactMap { eye -> CGPoint? in
            let hitTest = self.phonePlane.hitTestWithSegment(from: eye.target.worldPosition, to: eye.worldPosition)
            return hitTest.first?.screenPosition
        }
        
        
        print("PUNTOS DE INTERSECCIÓN: \(intersectPoints)")
        
        guard let leftPoint = intersectPoints.first, let rightPoint = intersectPoints.last else { return }
        
        let centerPoint = CGPoint(x: (leftPoint.x + rightPoint.x)/2, y: -(leftPoint.y + rightPoint.y)/2)
        
        eyeGazeHistory.append(centerPoint)
        eyeGazeHistory = eyeGazeHistory.suffix(numberOfSmoothUpdates)
        
        
        aimImageView.transform = eyeGazeHistory.averageAffineTransform

    }
    
    
    

}

    
    

    



extension SCNHitTestResult{
    var screenPosition : CGPoint{
        //Aquí va el cálculo de la colisión
        
        let physicalIphoneXSMaxSize = CGSize(width: 0.0696/2, height: 0.15/2)
        
        let sizeResolution = UIScreen.main.bounds.size
        
        let screenX = CGFloat(localCoordinates.x) / physicalIphoneXSMaxSize.width * sizeResolution.width
        
        let screenY = CGFloat(localCoordinates.y) / physicalIphoneXSMaxSize.height * sizeResolution.height
        
        return CGPoint(x: screenX, y: screenY)
        
    }
}

extension ArraySlice where Element == CGPoint{
    var averageAffineTransform : CGAffineTransform {
        var x : CGFloat = 0
        var y : CGFloat = 0
        
        for item in self{
            x += item.x
            y += item.y
        }
        
        let elementCount = CGFloat(self.count)
        return CGAffineTransform(translationX: x/elementCount, y: y/elementCount)
    }
}
