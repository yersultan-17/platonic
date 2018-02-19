//
//  objectSelection.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 10/24/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import SceneKit

extension ViewController {
    /**
     Adds the specified virtual object to the scene, placed using
     the focus square's estimate of the world-space position
     currently corresponding to the center of the screen.
     
     - Tag: PlaceVirtualObject
     */
    func placeVirtualObject(_ virtualObject: VirtualObject) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            let focusSquarePosition = focusSquare.lastPosition else {
              //  statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
                return
        }
        
     //   virtualObjectInteraction.selectedObject = virtualObject
        virtualObject.setPosition(object: virtualObject, newPosition: focusSquarePosition, relativeTo: cameraTransform, smoothMovement: false)
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(virtualObject)
        }
    }
    
}
