
import UIKit
import SceneKit

class Eye: SCNNode {
    
    let target = SCNNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("No lo vamos a implementar")
    }
    
    init(color: UIColor) {
        super.init()
        
        let cylinder = SCNCylinder(radius: 0.01, height: 0.15)
        cylinder.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: cylinder)
        node.eulerAngles.x = -.pi/2
        node.position.z = 0.075
        node.opacity = 0.4
        
        target.position.z = 1
        
        addChildNode(node)
        addChildNode(target)
        
    }
    
}
