//
//  ViewController.swift
//  bekobe-camera
//
//  Created by Yuki Ohyama on 2019/02/25.
//  Copyright © 2019 Yuki Ohyama. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Add tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Set the scene to the view
        sceneView.scene = SCNScene()

        // Add light
        let lightNode = SCNNode()
        lightNode .light = SCNLight()
        lightNode .light!.type = .omni
        lightNode .position = SCNVector3(x: 0, y: 0, z: 1)
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Add horizontal plane detection
        configuration.planeDetection = .horizontal

        // Show debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]

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
    @objc func tapped(recognizer: UIGestureRecognizer) {
        
        let view = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: view)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if hitTestResult.isEmpty == false {
            if let result = hitTestResult.first {

                let transform = result.worldTransform
                let thirdColumn = transform.columns.3
                
                // Create a new 3d object
                let scene = SCNScene(named: "bekobe.scnassets/bekobe.scn")!
                let item = scene.rootNode.childNode(withName: "bekobe", recursively: true)!
                item.position = SCNVector3(thirdColumn.x, thirdColumn.y + 0.02, thirdColumn.z)
                if let camera = sceneView.pointOfView {
                    item.eulerAngles.y = camera.eulerAngles.y
                }
                sceneView.scene.rootNode.addChildNode(item)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("Error: This anchor is not ARPlaneAnchor. [\(#function)]")
            return
        }
        
        let planeGeometory = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                      height: CGFloat(planeAnchor.extent.z))
        
        planeGeometory.materials.first?.diffuse.contents = UIColor.white
        
        let geometryPlaneNode = SCNNode(geometry: planeGeometory)
        geometryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        geometryPlaneNode.eulerAngles.x = -.pi / 2
        geometryPlaneNode.opacity = 0.2
        
        node.addChildNode(geometryPlaneNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("Error: This anchor is not ARPlaneAnchor. [\(#function)]")
            return
        }
        
        guard let geometryPlaneNode = node.childNodes.first,
            let planeGeometory = geometryPlaneNode.geometry as? SCNPlane else {
                print("Error: SCNPlane node is not found. [\(#function)]")
                return
        }
        
        geometryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeGeometory.width = CGFloat(planeAnchor.extent.x)
        planeGeometory.height = CGFloat(planeAnchor.extent.z)
    }
    
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
