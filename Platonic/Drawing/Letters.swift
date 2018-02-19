//
//  Letters.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/28/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import ARKit

extension VirtualObject {
    func createRectLetters(node: SCNNode) {
        for coord in vertices {
            let letter = SCNText(string: "B", extrusionDepth: 0.01)
            letter.font = UIFont.systemFont(ofSize: 0.1)
            letter.materials.first?.isDoubleSided = true
            letter.materials.first?.diffuse.contents = UIColor.black
            letter.materials.first?.specular.contents = UIColor.black
            let letterNode = SCNNode(geometry: letter)
            letterNode.position = coord
            letterNode.position.y -= 0.9
            letterNode.position.x -= 0.025
            letterNode.position.z += 0.05
            node.addChildNode(letterNode)
        }
    }
}
