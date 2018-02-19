//
//  crossSection.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/3/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import ARKit
import UIKit

class CrossSection {
    
    static let shared = CrossSection()
    
    func pointLocationRelativeToVector(vector: SCNVector3, vectorWithPoint: SCNVector3) -> Int {
        let answer = vector.x * vectorWithPoint.z - vector.z * vectorWithPoint.x
        if answer > 0 { return 1 }
        else if answer < 0 { return -1 }
        else { return 0 }
    }
    
      func getCrossSection(points: [SCNVector3]) -> SCNNode {
        let node = SCNNode()
        var indices = [Int32]()
        let sortedPoints = points.sorted(by: { ($0.x < $1.x) || ($0.x == $1.x && $0.y < $1.y) || ($0.x == $1.x && $0.y == $1.y && $0.z < $1.z) })
        
        
        var result = [(Int32, SCNVector3)]()
        for (index, point) in sortedPoints.enumerated() {
            result.append((Int32(index), point))
        }
    
        let first = result.removeFirst()
        for i in 0..<result.count - 1 {
            for j in i + 1..<result.count {
                let vector1 = Calculations.shared.getVectorAB(A: first.1, B: result[i].1)
                let vector2 = Calculations.shared.getVectorAB(A: first.1, B: result[j].1)
                let answer = pointLocationRelativeToVector(vector: vector1, vectorWithPoint: vector2)
                if answer == -1 {
                    result.swapAt(i, j)
                }
            }
        }
        for index in 0..<result.count - 1 {
            indices.append(contentsOf: [ 0, result[index].0, result[index + 1].0])
        }
        if sortedPoints.count == 4 {
            indices = [0, 1, 2, 1, 2, 3]
        }
        
        node.geometry = GetFigures.shared.getCustomTriangleGeometry(points: sortedPoints, indices: indices)
        node.geometry?.materials.first?.diffuse.contents = UIColor.orange
        node.geometry?.materials.first?.transparency = 1
        node.geometry?.materials.first?.isDoubleSided = true
        
        return node
    }
}

