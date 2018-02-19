//
//  sceneExtensions.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/25/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import Foundation
import ARKit

extension ARSCNView {
    
    func setup() {
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
        
        if let camera = pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = 3
        }
    }
}

extension SCNScene {
    
}
