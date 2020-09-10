//
//  FocusSquare.swift
//  ARApp
//
//  Created by Lê Hoàng Anh on 08/09/2020.
//

import SceneKit

final class FocusSquare: SCNNode {
    
    var isClosed: Bool = true {
        didSet {
            geometry?.firstMaterial?.diffuse.contents = isClosed ? UIImage(named: "close") : UIImage(named: "open")
        }
    }
    
    override init() {
        super.init()
        
        let plane = SCNPlane(width: 0.1, height: 0.1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "close")
        
        geometry = plane
        eulerAngles.x = GLKMathDegreesToRadians(-90)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // hide this view when camera point to an exist object
    func setHidden(_ hidden: Bool) {
        let fadeTo: SCNAction = hidden ? .fadeOut(duration: 0.5) : .fadeIn(duration: 0.5)
        let actions = [fadeTo, .run( { (focusSquare: SCNNode) in focusSquare.isHidden = hidden })]
        runAction(.sequence(actions))
    }
}
