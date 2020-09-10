//
//  ViewController.swift
//  ARApp2nd
//
//  Created by Lê Hoàng Anh on 09/09/2020.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var iPhoneXNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()

        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else { return }
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        configuration.isLightEstimationEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBAction func change(_ sender: Any) {
        iPhoneXNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/ARNewScreen.png")
    }
    
    @IBAction func plus(_ sender: Any) {
        let scale = SCNAction.scale(by: 2, duration: 2)
        iPhoneXNode.runAction(scale)
    }
    
    @IBAction func minus(_ sender: Any) {
        let scale = SCNAction.scale(by: 0.5, duration: 2)
        iPhoneXNode.runAction(scale)
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // To see this animation, run app and point camera to the "iPhone-x" image, it'll be shown above the image
        let node = SCNNode()
        if anchor is ARImageAnchor {
            let plane = SCNPlane(width: 0.7, height: 0.35)
            let deviceScene = SKScene(fileNamed: "DeviceScene")
            let animator = SCNAction.scale(by: 10, duration: 4)
            
            plane.firstMaterial?.diffuse.contents = deviceScene
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            var iPhoneNode = SCNNode()
            let iPhoneScene = SCNScene(named: "art.scnassets/iPhoneX.scn")!
            iPhoneNode = iPhoneScene.rootNode.childNodes.first!
            iPhoneNode.position = SCNVector3(0, 0, 0.15)
            node.addChildNode(planeNode)
            planeNode.addChildNode(iPhoneNode)
            
            let min = iPhoneNode.boundingBox.min
            let max = iPhoneNode.boundingBox.max
            
            let centerX = min.x + (max.x - min.x) / 2
            let centerY = min.y + (max.y - min.y) / 2
            let centerZ = min.z + (max.z - min.z) / 2
            
            iPhoneNode.pivot = SCNMatrix4MakeTranslation(centerX, centerY, centerZ)
            
            iPhoneNode.runAction(rotation())
            iPhoneNode.runAction(animator)
            iPhoneXNode = iPhoneNode
        }
        return node
    }
    
    func rotation() -> SCNAction {
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(360)), z: 0, duration: 3)
        let repeatAction = SCNAction.repeatForever(action)
        return repeatAction
    }
}
