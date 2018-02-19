//
//  createFigures.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/21/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import SceneKit
import ARKit

class GetFigures {

    static let shared = GetFigures()
    // MARK: Creating built-in figures
    
    func getCube(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "Cube"
        let edge = object.dimensions["Edge"]!
        node.geometry = SCNBox(width: edge, height: edge, length: edge, chamferRadius: 0)
        Points.shared.getRectVertices(object: object, node: node)
        Lines.shared.drawBordersRectPrism(object: object, node: node)
        return node
    }
    
     func getRectPrism(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "rectPrism"
        let width = object.dimensions["Width"]!
        let height = object.dimensions["Height"]!
        let length = object.dimensions["Length"]!
        node.geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        Points.shared.getRectVertices(object: object, node: node)
        Lines.shared.drawBordersRectPrism(object: object, node: node)
        return node
    }
    
     func getSphere(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "Sphere"
        let radius = object.dimensions["Radius"]!
        node.geometry = SCNSphere(radius: radius)
        Lines.shared.drawBordersSphere(radius: radius, node: node)
       //   vertices = [node.boundingSphere.center]
        return node
    }
    
     func getCone(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "Cone"
        let bottomRadius = object.dimensions["Radius"]!
        let height = object.dimensions["Height"]!
        let geometry = SCNCone(topRadius: 0, bottomRadius: bottomRadius, height: height)
        node.geometry = geometry
        Points.shared.getConicVertices(object: object, bottomRadius: bottomRadius, height: height, node: node)
        Lines.shared.drawBordersCone(object: object, bottomCenter: object.vertices[0], bottomRadius: bottomRadius, node: node)
        return node
    }
    
    
     func getCuttedCone(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "cuttedCone"
        let bottomRadius = object.dimensions["Bottom Radius"]!
        let topRadius = object.dimensions["Top Radius"]!
        let height = object.dimensions["Height"]!
        let geometry = SCNCone(topRadius: topRadius, bottomRadius: bottomRadius, height: height)
        node.geometry = geometry
        Points.shared.getConicVertices(object: object, bottomRadius: bottomRadius, height: height, node: node)
        Lines.shared.drawBordersCuttedCone(object: object, bottomCenter: object.vertices[0], bottomRadius: bottomRadius, topCenter: object.vertices[1], topRadius: topRadius, node: node)
        return node
    }
    
     func getCylinder(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "Cylinder"
        let radius = object.dimensions["Radius"]!
        let height = object.dimensions["Height"]!
        let geometry = SCNCylinder(radius: radius, height: height)
        node.geometry = geometry
        Points.shared.getConicVertices(object: object, bottomRadius: radius, height: height, node: node)
        Lines.shared.drawBordersCylinder(object: object, bottomCenter: object.vertices[0], topCenter: object.vertices[1], radius: radius, node: node)
        return node
    }
    
     func getRectPyramid(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "rectPyramid"
        let width = object.dimensions["Width"]!
        let height = object.dimensions["Height"]!
        let length = object.dimensions["Length"]!
        let geometry = SCNPyramid(width: width, height: height, length: length)
        node.geometry = geometry
        Points.shared.getRectPyramidVertices(object: object, min: node.boundingBox.min, width: width, length: length, height: height, node: node)
        Lines.shared.drawBordersRectPyramid(object: object, node: node)
        return node
    }
    
     func getPlane(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "Plane"
        let width = object.dimensions["Width"]!
        let height = 0.2 //object.dimensions["Height"]!
        let geometry = SCNPlane(width: width, height: CGFloat(height))
        node.geometry = geometry
        node.rotation = SCNVector4Make(1, 0, 0, Float(Double.pi / 2))
        Lines.shared.drawBordersPlane(object: object, min: (node.geometry?.boundingBox.min)!, max: (node.geometry?.boundingBox.max)!, width: width, node: node)
        return node
    }
    
    
    // MARK: Creating custom figures
    
     func getTrianglePrism(object: VirtualObject) -> SCNNode{
        let node = SCNNode()
        node.name = "trianglePrism"
        object.vertices = [SCNVector3Make(0.0, 0.3, 0.0),
                    SCNVector3Make(-0.1, 0.0, 0.0),
                    SCNVector3Make(0.1, 0.0, 0.0),
                    SCNVector3Make(0.0, 0.3, 0.3),
                    SCNVector3Make(-0.1, 0.0, 0.3),
                    SCNVector3Make(0.1, 0.0, 0.3)]
        let indices:[Int32] = [0, 1, 2,
                               3, 4, 5,
                               3, 5, 0,
                               0, 5, 2,
                               4, 3, 0,
                               0, 1, 4,
                               4, 1, 5,
                               1, 5, 2]
         node.geometry = getCustomTriangleGeometry(points: object.vertices, indices: indices)
        
        Lines.shared.drawBordersTrianglePrism(object: object, node: node)
        return node
    }
    
     func getTrianglePyramid(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "trianglePyramid"
        object.vertices = [SCNVector3Make(0, 0, 0),
                                  SCNVector3Make(0.4, 0, 0),
                                  SCNVector3Make(0.2, 0, 0.346),
                                  SCNVector3Make(0.2, 0.326, 0.115)]
        let indices:[Int32] = [0, 1, 2,
                               0, 2, 3,
                               0, 1, 3,
                               3, 2, 1]
        node.geometry = getCustomTriangleGeometry(points: object.vertices, indices: indices)
        Lines.shared.drawBordersTrianglePyramid(object: object, node: node)
        return node
    }
    
    func getRightAngledTetrahedron(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        node.name = "rightAngledTetrahedron"
        object.vertices = [SCNVector3Make(0, 0, 0),
                           SCNVector3Make(0, 0, 0.4),
                            SCNVector3Make(0.3, 0, 0.4),
                            SCNVector3Make(0, 0.6, 0)]
        let indices:[Int32] = [0, 1, 2,
                               0, 2, 3,
                               0, 1, 3,
                               1, 2, 3]
        node.geometry = getCustomTriangleGeometry(points: object.vertices, indices: indices)
        Lines.shared.drawBordersTrianglePyramid(object: object, node: node)
        return node
    }
    
     func getLine(object: VirtualObject) -> SCNNode {
        let node = SCNNode()
        let a = SCNVector3Make(0, 0, 0)
        let b = SCNVector3Make(0.3, 0.3, 0.3)
        
        object.vertices = [a,b]
        
        let lineNode = Lines.shared.createLineNode(from: a, to: b)
        node.addChildNode(lineNode)
        
        return node
    }
    
     func getCustomTriangleGeometry(points: [SCNVector3] ,indices: [Int32]) -> SCNGeometry {
        let vertexData = NSData(bytes: points, length: points.count * MemoryLayout<SCNVector3>.size)
        let vertexSource = SCNGeometrySource(data: vertexData as Data, semantic: SCNGeometrySource.Semantic.vertex, vectorCount: points.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float>.size, dataOffset: 0, dataStride: MemoryLayout<SCNVector3>.size)
        let indexData = NSData(bytes: indices, length: indices.count * MemoryLayout<Int32>.size)
        let indexElement = SCNGeometryElement(data: indexData as Data, primitiveType: .triangles, primitiveCount: indices.count / 3, bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [indexElement])
        return geometry
    }
}
