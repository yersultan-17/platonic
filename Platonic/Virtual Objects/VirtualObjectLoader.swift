//
//  VirtualObjectLoader.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 10/23/17.
//  Copyright © 2017 Yersultan Sapar. Albl rights reserved.
//

import Foundation
import ARKit

class VirtualObjectLoader {
//   var usingObjects = VirtualObject.availableObjects
    
    var usingObjects = [VirtualObject]()
    
    private(set) var loadedObjects = [VirtualObject]()
    
    private(set) var isLoading = false
    
    // MARK: - Loading object
    
    /**
     Loads a `VirtualObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
     */
    func loadVirtualObject(_ object: VirtualObject, loadedHandler: @escaping (VirtualObject) -> Void) {
        isLoading = true
        loadedObjects.append(object)
        
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.reset()
            
            self.isLoading = false
            loadedHandler(object)
        }
    }
    
    // MARK: - Removing Objects
    
    func removeAllVirtualObjects() {
        // Reverse the indicies so we don't trample over indicies as objects are removed.
        for index in loadedObjects.indices.reversed() {
            removeVirtualObject(at: index)
        }
        usingObjects.removeAll()
        getAvailableFigures()
    }
    
    func removeVirtualObject(at index: Int) {
        guard loadedObjects.indices.contains(index) else { return }
        
        loadedObjects[index].removeFromParentNode()
        loadedObjects.remove(at: index)
    }
    
    func getAvailableFigures() {
        usingObjects = [  VirtualObject(type: .cube, image: #imageLiteral(resourceName: "cubeIcon"), custom: false),
                          VirtualObject(type: .rectPrism, image: #imageLiteral(resourceName: "recPrismIcon"), custom: false),
                          VirtualObject(type: .trianglePrism, image: #imageLiteral(resourceName: "trianglePrismIcon"), custom: true),
                          VirtualObject(type: .sphere, image: #imageLiteral(resourceName: "sphereIcon"), custom: false),
                          VirtualObject(type: .cone, image: #imageLiteral(resourceName: "coneIcon"), custom: false),
                          VirtualObject(type: .cuttedCone, image: #imageLiteral(resourceName: "cuttedConeIcon"), custom: false),
                          VirtualObject(type: .cylinder, image: #imageLiteral(resourceName: "cylinderIcon"), custom: false),
                          VirtualObject(type: .rectPyramid, image: #imageLiteral(resourceName: "rectPyramidIcon"), custom: false),
                          VirtualObject(type: .trianglePyramid, image: #imageLiteral(resourceName: "trianglePyramidIcon"), custom: true),
                          VirtualObject(type: .rightAngledTetrahedron, image: #imageLiteral(resourceName: "rightAngledTetrahedronIcon"), custom: true),
                          VirtualObject(type: .plane, image: #imageLiteral(resourceName: "planeIcon"), custom: false),
                          VirtualObject(type: .cube, image: #imageLiteral(resourceName: "lineIcon"), custom: true)]
    }
    
    // MARK: - My functions from deprecated manager
    
    func getVirtualObjectWithNode(node: SCNNode) -> VirtualObject? {
        for object in loadedObjects {
            if object.objectNode == node { return object }
        }
        return nil
    }
    
    // there should be unload virtual object stuff
  
    
    // here is transform, world position calculations guess I dont need em
    
}

