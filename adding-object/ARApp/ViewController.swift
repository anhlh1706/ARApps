//
//  ViewController.swift
//  ARApp
//
//  Created by Lê Hoàng Anh on 08/09/2020.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var focusSquare: FocusSquare?
    var centerView: CGPoint!
    var models = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerView = view.center
        
        sceneView.delegate = self
        
        sceneView.debugOptions = .showFeaturePoints
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // in this case, update center view when the orientation of device changed
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        centerView = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    func updateFocusSquare() {
        guard let focusSquare = focusSquare else { return }
        
        // Hide focusSquare when camera point to model
        guard let pointOfView = sceneView.pointOfView else { return }
        let firstVisibleModel = models.first(where: { self.sceneView.isNode($0, insideFrustumOf: pointOfView) })
        
        let modelsAreVisible = firstVisibleModel != nil
        if modelsAreVisible != focusSquare.isHidden {
            focusSquare.setHidden(modelsAreVisible)
        }
        
        // Changes center icon when plane is available or not
        let hitTest = sceneView.hitTest(centerView, types: .existingPlaneUsingExtent)
        if let hitTestResult = hitTest.first {
            let isAddNewModel = hitTestResult.anchor is ARPlaneAnchor
            focusSquare.isClosed = isAddNewModel
        } else {
            focusSquare.isClosed = false
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        guard focusSquare != nil, !focusSquare?.isClosed ?? false else { return }
        let modelName = "iPhoneX" // name of folder contains sources file .scn
        guard let model = getModel(ofName: modelName) else {
            print("Unable to get \(modelName) from files.")
            return
        }
        let hitTest = sceneView.hitTest(centerView, types: .existingPlaneUsingExtent)
        guard let worldTransformColumn3 = hitTest.first?.worldTransform.columns.3 else { return }
        model.position = SCNVector3(worldTransformColumn3.x, worldTransformColumn3.y, worldTransformColumn3.z)
        
        sceneView.scene.rootNode.addChildNode(model)
        models.append(model)
    }
    
    func getModel(ofName name: String) -> SCNNode? {
        let scene = SCNScene(named: "art.scnassets/\(name)/\(name).scn")
        guard let model = scene?.rootNode.childNode(withName: "SketchUp", recursively: false) else { return nil }
        
        model.name = name
        return model
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard focusSquare == nil else { return }
        let localFocusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(localFocusSquare)
        focusSquare = localFocusSquare
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    // Call after camera changed
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let focusSquare = focusSquare else { return }
        let hitTest = sceneView.hitTest(centerView, types: .existingPlane)
        let hitTestResult = hitTest.first
        guard let worldTransform = hitTestResult?.worldTransform else { return }
        let worldTransform3 = worldTransform.columns.3
        focusSquare.position = SCNVector3(worldTransform3.x, worldTransform3.y, worldTransform3.z)
        
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
}
