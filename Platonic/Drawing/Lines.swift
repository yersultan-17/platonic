//
//  Borders.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/21/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import SceneKit
import ARKit

struct Line {
    let node: SCNNode
    let startPoint: SCNVector3
    let endPoint: SCNVector3
    let initLength: Float
    var longLength: Float
    var longStartPoint: SCNVector3
    var longEndPoint: SCNVector3
    var lambda: Float
    
    
    init(node: SCNNode, startPoint: SCNVector3, endPoint: SCNVector3) {
        self.node = node
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.initLength = Calculations.shared.getDistance(from: startPoint, to: endPoint)
        self.longStartPoint = startPoint
        self.longEndPoint = endPoint
        self.longLength = self.initLength
        
        self.lambda = self.longLength / 2
    }
    
    func getLength() -> Float {
        return sqrtf((endPoint.x - startPoint.x) * (endPoint.x - startPoint.x) + (endPoint.y - startPoint.y) * (endPoint.y - startPoint.y) + (endPoint.z - startPoint.z) * (endPoint.z - startPoint.z))
    }
    
    func getCanonicEquation() -> (Float, Float, Float, Float, Float, Float) {
        let x1 = startPoint.x
        let y1 = startPoint.y
        let z1 = startPoint.z
        
        let p = endPoint.x - x1
        let q = endPoint.y - y1
        let r = endPoint.z - z1
        
        return (x1, p, y1, q, z1, r)
    }
    
    func getParametricEquation() -> (SCNVector3, SCNVector3) {
        let point = startPoint
        let normal = Calculations.shared.getVectorAB(A: startPoint, B: endPoint)
        return (normal, point)
    }
    
    static func ==(lhs: Line, rhs: Line) -> Bool {
        return lhs.node == rhs.node && lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint
    }
    
}

class Lines {
    static let shared = Lines()
    
    func getCanonicEqOfParallelLine(to line: Line, through point: SCNVector3) -> (Float, Float, Float, Float, Float, Float) {
        let (_, p, _, q, _, r) = line.getCanonicEquation()
        return (point.x, p, point.y, q, point.z, r)
    }
    
    func linesAreOnSamePlaneForParallel(a: SCNVector3, aPoint: SCNVector3, bLine: Line) -> Bool {
        let (b, bPoint) = bLine.getParametricEquation()
        let r = Calculations.shared.getVectorAB(A: aPoint, B: bPoint)
        if ((r.x * a.y * b.z + b.x * r.y * a.z + a.x * b.y * r.z - b.x * a.y * r.z - r.x * b.y * a.z - a.x * r.y * b.z) == 0) { return true }
        return false
    }
    
    func linesAreOnSamePlane(aLine: Line, bLine: Line) -> Bool {
        let (a, aPoint) = aLine.getParametricEquation()
        let (b, bPoint) = bLine.getParametricEquation()
        let r = Calculations.shared.getVectorAB(A: aPoint, B: bPoint)
        if ((r.x * a.y * b.z + b.x * r.y * a.z + a.x * b.y * r.z - b.x * a.y * r.z - r.x * b.y * a.z - a.x * r.y * b.z) == 0) { return true }
        return false
    }
    
    func linesAreCollinearForParallel(aNormal: SCNVector3, bLine: Line) -> Bool {
        let bNormal = Calculations.shared.getVectorAB(A: bLine.startPoint, B: bLine.endPoint)
        
        let (x1, y1, z1) = aNormal.getComponents()
        let (x2, y2, z2) = bNormal.getComponents()
        var a: Float = 0, b: Float = 0, c: Float = 0
        
        if (x1 != 0) { a = x2 / x1 } else if (x2 != 0) { a = x1 / x2 }
        if (y1 != 0) { b = y2 / y1 } else if (y2 != 0) { a = y1 / y2 }
        if (z1 != 0) { c = z2 / z1 } else if (z2 != 0) { a = z1 / z2 }
        
        if ((a == b) && (b == c)) { return true }
        return false
    }
    
    func linesAreCollinear(aLine: Line, bLine: Line) -> Bool {
        let aNormal = Calculations.shared.getVectorAB(A: aLine.startPoint, B: aLine.endPoint)
        let bNormal = Calculations.shared.getVectorAB(A: bLine.startPoint, B: bLine.endPoint)
        
        let (x1, y1, z1) = aNormal.getComponents()
        let (x2, y2, z2) = bNormal.getComponents()
        var a: Float = 0, b: Float = 0, c: Float = 0
        
        if (x1 != 0) { a = x2 / x1 } else if (x2 != 0) { a = x1 / x2 }
        if (y1 != 0) { b = y2 / y1 } else if (y2 != 0) { a = y1 / y2 }
        if (z1 != 0) { c = z2 / z1 } else if (z2 != 0) { a = z1 / z2 }
        
        if ((a == b) && (b == c)) { return true }
        return false
    }
    
    func lengthenLineNode(node: SCNNode, to: Float) {
        guard let geometry = node.geometry else { return }
        if let name = geometry.name, let height = Float(name) {
            let finalHeight = CGFloat(height + to)
            let cyl = SCNCylinder(radius: 0.002, height: finalHeight)
            node.geometry = cyl
            node.geometry?.name = String(describing: finalHeight)
            node.geometry?.materials.first?.diffuse.contents = UIColor.black
        }
    }
    
    func getLineNodesWithEgde(object: VirtualObject, edge: SCNVector3) -> [SCNNode] {
        var result = [SCNNode]()
        for line in object.lines {
            if (line.startPoint == edge) { result.append(line.node) }
        }
        return result
    }
    
      func getLineWithNode(object: VirtualObject, node: SCNNode) -> Line? {
        for line in object.lines {
            if line.node == node { return line }
        }
        return nil
    }
    
      func getLineNodeWithPoints(object: VirtualObject, startPoint: SCNVector3, endPoint: SCNVector3) -> SCNNode? {
        for line in object.lines {
            if (startPoint == line.startPoint && endPoint == line.endPoint) { return line.node }
            if (startPoint == line.endPoint && endPoint == line.startPoint) { return line.node }
        }
        return nil
    }
    
    func adjustLineNode(node: SCNNode, startPoint: SCNVector3, endPoint: SCNVector3) {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        let cyl = SCNCylinder(radius: 0.002, height: l)
        cyl.firstMaterial?.diffuse.contents = UIColor.black
        cyl.name = String(describing: l)
        node.geometry = cyl
        
        if (w.x == 0.0 && w.z == 0.0) {
            node.position = SCNVector3Make(startPoint.x, (startPoint.y + endPoint.y) / 2.0, startPoint.z)
        } else if (w.y == 0.0 && w.z == 0) {
            node.position =  SCNVector3Make((startPoint.x + endPoint.x) / 2.0, startPoint.y, startPoint.z)
            node.rotation = SCNVector4Make(0, 0, 1, Float(Double.pi / 2))
        } else if (w.x == 0.0 && w.y == 0) {
            node.position = SCNVector3Make(startPoint.x, startPoint.y, (startPoint.z + endPoint.z) / 2.0)
            node.rotation = SCNVector4Make(1, 0, 0, Float(Double.pi / 2))
        } else {
            //original vector of cylinder above 0,0,0
            let ov = SCNVector3(0, l/2.0,0)
            //target vector, in new coordination
            let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                                (endPoint.z-startPoint.z)/2.0)
            
            // axis between two vector
            let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
            
            //normalized axis vector
            let av_normalized = Calculations.shared.normalizeVector(av)
            let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
            let q1 = Float(av_normalized.x) // x' * sin(angle/2)
            let q2 = Float(av_normalized.y) // y' * sin(angle/2)
            let q3 = Float(av_normalized.z) // z' * sin(angle/2)
            
            let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
            let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
            let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
            let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
            let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
            let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
            let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
            let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
            let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
            
            node.transform.m11 = r_m11
            node.transform.m12 = r_m12
            node.transform.m13 = r_m13
            node.transform.m14 = 0.0
            
            node.transform.m21 = r_m21
            node.transform.m22 = r_m22
            node.transform.m23 = r_m23
            node.transform.m24 = 0.0
            
            node.transform.m31 = r_m31
            node.transform.m32 = r_m32
            node.transform.m33 = r_m33
            node.transform.m34 = 0.0
            
            node.transform.m41 = (startPoint.x + endPoint.x) / 2.0
            node.transform.m42 = (startPoint.y + endPoint.y) / 2.0
            node.transform.m43 = (startPoint.z + endPoint.z) / 2.0
            node.transform.m44 = 1.0
        }
    }


      func createLineNode(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNNode {
        let resultNode = SCNNode()
        resultNode.name = "Line"
        adjustLineNode(node: resultNode, startPoint: startPoint, endPoint: endPoint)
        
        return resultNode
    }
    
      func drawBorders(object: VirtualObject, indices: [Int], node: SCNNode, points: [SCNVector3] = []) {
        var indexPoints = [SCNVector3]()
        if points.isEmpty { indexPoints = object.vertices } else { indexPoints = points }
        for index in stride(from: 0, to: indices.count, by: 2) {
            let startPoint = indexPoints[indices[index]]
            let endPoint = indexPoints[indices[index + 1]]
            let lineNode = createLineNode(from: startPoint, to: endPoint)
            lineNode.name = "Border"
            node.addChildNode(lineNode)
            
         //   let worldStartPoint = node.convertPosition(startPoint, to: nil)
          //  let worldEndPoint = node.convertPosition(endPoint, to: nil)

            
            object.lines.append(Line(node: lineNode, startPoint: startPoint, endPoint: endPoint))
        }
    }
    
      func getTorusNode(_ radius: CGFloat) -> SCNNode {
        let torusNode = SCNNode()
        let geometry = SCNTorus(ringRadius: radius, pipeRadius: 0.003)
        geometry.pipeSegmentCount = 34
        geometry.ringSegmentCount = 134
        torusNode.geometry = geometry
        torusNode.geometry?.materials.first?.diffuse.contents = UIColor.black
        torusNode.geometry?.materials.first?.specular.contents = UIColor.black
        torusNode.name = "Border"
        return torusNode
    }
    
    func drawBordersRectPrism(object: VirtualObject, node: SCNNode) {
        let indices = [0, 1,
                       1, 2,
                       2, 3,
                       3, 0,
                       4, 5,
                       5, 6,
                       6, 7,
                       7, 4,
                       0, 4,
                       1, 5,
                       2, 6,
                       3, 7]
        drawBorders(object: object, indices: indices, node: node)
    }
    
      func drawBordersSphere(radius: CGFloat, node: SCNNode) {
        let equatorNode = getTorusNode(radius)
        node.addChildNode(equatorNode)
        
        let anotherNode = getTorusNode(radius)
        anotherNode.rotation = SCNVector4Make(0, 0, 1, Float(Double.pi / 2))
        node.addChildNode(anotherNode)
    }
    
    
      func drawBordersTrianglePrism(object: VirtualObject, node: SCNNode) {
        let indices = [0, 1,
                       1, 2,
                       0, 2,
                       3, 4,
                       3, 5,
                       4, 5,
                       0, 3,
                       1, 4,
                       2, 5]
        drawBorders(object: object, indices: indices, node: node)
    }
    
      func drawBordersCone(object: VirtualObject, bottomCenter: SCNVector3, bottomRadius: CGFloat, node: SCNNode) {
        let bottomBorderNode = getTorusNode(bottomRadius)
        bottomBorderNode.position = bottomCenter
        node.addChildNode(bottomBorderNode)
        
        var coneVertices = object.vertices
        var point1 = bottomCenter, point2 = bottomCenter
        point1.x += Float(bottomRadius)
        point2.x -= Float(bottomRadius)
        coneVertices.append(contentsOf: [point1, point2])
        
        let indices = [1, 3,
                       1, 2]
        drawBorders(object: object, indices: indices, node: node, points: coneVertices)
    }
    
      func drawBordersCuttedCone(object: VirtualObject, bottomCenter: SCNVector3, bottomRadius: CGFloat, topCenter: SCNVector3, topRadius: CGFloat, node: SCNNode) {
        let bottomBorderNode = getTorusNode(bottomRadius)
        bottomBorderNode.position = bottomCenter
        node.addChildNode(bottomBorderNode)
        
        let topBorderNode = getTorusNode(topRadius)
        topBorderNode.position = topCenter
        node.addChildNode(topBorderNode)
        
        
        var cuttedConeVertices = object.vertices
        var bottomPoint1 = bottomCenter, bottomPoint2 = bottomCenter, topPoint1 = topCenter, topPoint2 = topCenter
        topPoint1.x -= Float(topRadius)
        topPoint2.x += Float(topRadius)
        bottomPoint1.x -= Float(bottomRadius)
        bottomPoint2.x += Float(bottomRadius)
        
        cuttedConeVertices.append(contentsOf: [topPoint1, topPoint2, bottomPoint1, bottomPoint2])
        
        let indices = [2, 4,
                       3, 5]
        drawBorders(object: object, indices: indices, node: node, points: cuttedConeVertices)
    }
    
      func drawBordersCylinder(object: VirtualObject, bottomCenter: SCNVector3, topCenter: SCNVector3, radius: CGFloat, node: SCNNode) {
        let bottomBorderNode = getTorusNode(radius)
        bottomBorderNode.position = bottomCenter
        node.addChildNode(bottomBorderNode)
        
        let topBorderNode = getTorusNode(radius)
        topBorderNode.position = topCenter
        node.addChildNode(topBorderNode)
        
        var cylinderVertices = object.vertices
        var bottomPoint1 = bottomCenter, bottomPoint2 = bottomCenter, topPoint1 = topCenter, topPoint2 = topCenter
        topPoint1.x -= Float(radius)
        topPoint2.x += Float(radius)
        bottomPoint1.x -= Float(radius)
        bottomPoint2.x += Float(radius)
        
        cylinderVertices.append(contentsOf: [topPoint1, topPoint2, bottomPoint1, bottomPoint2])
        

        let indices = [2, 4,
                       3, 5]

        drawBorders(object: object, indices: indices, node: node, points: cylinderVertices)
    }
    
      func drawBordersRectPyramid(object: VirtualObject, node: SCNNode) {
        let indices = [0, 1,
                       1, 2,
                       2, 3,
                       3, 0,
                       4, 0,
                       4, 1,
                       4, 2,
                       4, 3]
        drawBorders(object: object, indices: indices, node: node)
    }
    
      func drawBordersTrianglePyramid(object: VirtualObject, node: SCNNode) {
        let indices = [0, 1,
                       0, 2,
                       1, 2,
                       0, 3,
                       1, 3,
                       2, 3]
        drawBorders(object: object, indices: indices, node: node)
    }
    
      func drawBordersPlane(object: VirtualObject, min: SCNVector3, max: SCNVector3, width: CGFloat, node: SCNNode) {
        let vertex0 = min
        let vertex1 = SCNVector3(min.x + Float(width), min.y, min.z)
        let vertex2 = max
        let vertex3 = SCNVector3(max.x - Float(width), max.y, max.z)
        
        object.vertices = [vertex0, vertex1, vertex2, vertex3]
        
        let indices = [0, 1,
                       1, 2,
                       2, 3,
                       3, 0]
        drawBorders(object: object, indices: indices, node: node)
    }
}


