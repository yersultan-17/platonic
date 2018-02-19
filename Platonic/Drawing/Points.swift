//
//  Vertices.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/21/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import SceneKit
import ARKit

class Points {
    
    static let shared = Points()
    
     func highlightPoint(node: SCNNode) {
        if node.geometry?.name == "Highlighted" {
            node.geometry?.materials.first?.diffuse.contents = UIColor.black
            node.geometry?.name = "Unhighlighted"
        } else {
            node.geometry?.materials.first?.diffuse.contents = UIColor.red
            node.geometry?.name = "Highlighted"
        }
    }
    
     func highlightPointForUserLine(node: SCNNode) {
        node.geometry?.materials.first?.diffuse.contents = UIColor.green

    }
    
    func pointExistsOnPos(object: VirtualObject, position: SCNVector3) -> Bool {
        for point in object.points {
            if point.worldPosition == position { return true }
        }
        return false
    }
    
    
    // MARK: - Create a point
    
     func createPoint() -> SCNNode{
        let pointNode = SCNNode()
        let geometry = SCNSphere(radius: 0.01)
        geometry.segmentCount = 34
        
        pointNode.name = "Point"
        pointNode.geometry = geometry
        pointNode.geometry?.materials.first?.diffuse.contents = UIColor.black
        pointNode.geometry?.name = "Unhighlighted"
        
        return pointNode
    }
    
    func createPointsOnVertices(object: VirtualObject, node: SCNNode) {
        for coord in object.vertices {
            let pointNode = createPoint()
            pointNode.position = coord
            pointNode.name = "vertexPoint"
            node.addChildNode(pointNode)
            
            object.points.append(pointNode)
        }
    }
    
    func createPointOnCenter(object: VirtualObject, node: SCNNode) {
        let pointNode = createPoint()
        node.addChildNode(pointNode)
        
        object.points.append(pointNode)
        
    }
    
    // MARK: - Get coordinates of vertices
    
     func getRectVertices(object: VirtualObject,node: SCNNode) {
        let minn = node.geometry?.boundingBox.min
        let maxx = node.geometry?.boundingBox.max
        let max = ((maxx?.x)!, (maxx?.y)!, (maxx?.z)!)
        let min = ((minn?.x)!, (minn?.y)!, (minn?.z)!)
        object.vertices = [SCNVector3(min.0, min.1, min.2),
                    SCNVector3(max.0, min.1, min.2),
                    SCNVector3(max.0, min.1, max.2),
                    SCNVector3(min.0, min.1, max.2),
                    SCNVector3(min.0, max.1, min.2),
                    SCNVector3(max.0, max.1, min.2),
                    SCNVector3(max.0, max.1, max.2),
                    SCNVector3(min.0, max.1, max.2)]
    }
    
     func getConicVertices(object: VirtualObject, bottomRadius: CGFloat, height: CGFloat, node: SCNNode) {
        var bottomCenter = node.boundingSphere.center
        bottomCenter.y = node.boundingBox.min.y
        
        var topVertex = bottomCenter
        topVertex.y += Float(height)
        
         object.vertices = [bottomCenter, topVertex]
    }
    
     func getRectPyramidVertices(object: VirtualObject, min: SCNVector3, width: CGFloat, length: CGFloat, height: CGFloat, node: SCNNode) {
        
        let vertex0 = min
        let vertex1 = SCNVector3(min.x + Float(width), min.y, min.z)
        let vertex2 = SCNVector3(min.x + Float(width), min.y, min.z + Float(length))
        let vertex3 = SCNVector3(min.x, min.y, min.z + Float(length))
        
        let bottomCenter = SCNVector3((vertex0.x + vertex2.x) / 2, (vertex0.y + vertex2.y) / 2, (vertex0.z + vertex2.z) / 2)
        var topVertex = bottomCenter
        topVertex.y += Float(height)
        
        object.vertices = [vertex0, vertex1, vertex2, vertex3, topVertex]
    }
}
