//
//  ViewController.swift
//  Ej1MyFirsARApp
//
//  Created by lucas on 13/04/2019.
//  Copyright © 2019 lucas. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureRecognizer: )))
        view.addGestureRecognizer(tapGesture)
        
        
        
        
        
      
    }
    
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        //creamos un plano con una imagen usando una instantanea de la vista
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
        print (sceneView.bounds.width)
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        
        // Creamos un node con el plano y lo añadimo a la escena
        let nodePlane = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(nodePlane)
        
        
        // Aplicamos la trasnlación al nodo para que se situe 10cm en frente de la cámara
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        nodePlane.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
