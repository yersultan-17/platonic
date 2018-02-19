//
//  objectSelection.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/26/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import SceneKit

/* extension ViewController: VirtualObjectManagerDelegate {
    
    
    // MARK: - Manager delegate callbacks
    
    func virtualObjectManager(_ manager: VirtualObjectManager, willLoad object: VirtualObject) {
        print("")
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, didLoad object: VirtualObject) {
        print("")
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlace object: VirtualObject) {
        print("COULD NOT PLACE AN OBJECT")
    }
    
    // MARK: - Selection functions
    func virtualObjectSelection(_: ViewController, didSelectObjectAt index: Int) {
        guard let cameraTransform = session.currentFrame?.camera.transform else { return }
        
        let definition = VirtualObjectManager.availableObjects[index]
        let object = VirtualObject(definition: definition)
        selectedFigureNode = object.objectNode
        selectedObject = object
        
        print("SELECTED FIGURE IS - \(String(describing: selectedFigureNode?.name))")
        let position = focusSquare?.lastPosition ?? float3(0)
        object.currentPosition = position
        virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
        
        if object.parent == nil {
            serialQueue.async {
                self.sceneView.scene.rootNode.addChildNode(object)
            }
        }
    }
    
    func virtualObjectSelection(_: ViewController, didDeselectObjectAt index: Int) {
        virtualObjectManager.removeVirtualObject(at: index)
    }
  
   
} */
