//
//  VirtualObject.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 10/23/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import ARKit

protocol Copying {
    init(original: Self)
}

enum Figure: String {
    case cube = "Cube"
    case trianglePrism = "Triangular Prism" // custom
    case rectPrism = "Rectangular Prism"
    case sphere = "Sphere"
    case cone = "Cone"
    case cuttedCone = "Cutted Cone"
    case cylinder = "Cylinder"
    case rectPyramid = "Rectangular Pyramid"
    case trianglePyramid = "Triangular Pyramid" // custom
    case rightAngledTetrahedron = "Right-angled Tetrahedron" // custom
    case plane = "Plane"
    case line = "Line" // custom
}

class VirtualObject: SCNNode, Copying {
    /// The model name derived from the `referenceURL`.
//    var modelName: String {
//        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
//    }

    private var recentVirtualObjectDistances = [Float]()
    
    // MARK: Including VirtObjDefinition properties
    
    let type: Figure
    let objectName: String
    let custom: Bool
    var icon = UIImage()
    
    func getParameters() -> [String] {
        switch type {
        case .cube:
            return ["Edge"]
        case .trianglePrism:
            return ["Edge", "Height"]
        case .rectPrism:
            return ["Width", "Length", "Height"]
        case .sphere:
            return ["Radius"]
        case .cone:
            return ["Radius", "Height"]
        case .cuttedCone:
            return ["Bottom Radius", "Top Radius", "Height"]
        case .cylinder:
            return ["Radius", "Height"]
        case .rectPyramid:
            return ["Width", "Length", "Height"]
        case .trianglePyramid:
            return ["Edge", "Height"]
        case .rightAngledTetrahedron:
            return ["Catheter1", "Catheter2", "Height"]
        case .plane:
            return ["Width", "Length"]
        case .line:
            return ["Length"]
        }
    }
    
    // MARK: Virtual Object properties
    
    var vertices: [SCNVector3] = []
    var lines: [Line] = []
    var objectNode: SCNNode
    var dimensions = [String: CGFloat]()
    var currentPosition: float3
    var points: [SCNNode] = []
    
    func getFigureNode(type figure: Figure, object: VirtualObject) -> SCNNode {
        var figureNode = SCNNode()
        
        switch figure {
        case .cube: figureNode = GetFigures.shared.getCube(object: object)
        case .trianglePrism: figureNode = GetFigures.shared.getTrianglePrism(object: object)
        case .rectPrism: figureNode = GetFigures.shared.getRectPrism(object: object)
        case .sphere: figureNode = GetFigures.shared.getSphere(object: object)
        case .cone: figureNode = GetFigures.shared.getCone(object: object)
        case .cuttedCone: figureNode = GetFigures.shared.getCuttedCone(object: object)
        case .cylinder: figureNode = GetFigures.shared.getCylinder(object: object)
        case .rectPyramid: figureNode = GetFigures.shared.getRectPyramid(object: object)
        case .trianglePyramid: figureNode = GetFigures.shared.getTrianglePyramid(object: object)
        case .rightAngledTetrahedron: figureNode = GetFigures.shared.getRightAngledTetrahedron(object: object)
        case .plane: figureNode = GetFigures.shared.getPlane(object: object)
        case .line: figureNode = GetFigures.shared.getLine(object: object)
        }
        
        figureNode.geometry?.materials.first?.diffuse.contents = UIColor.white
        figureNode.geometry?.materials.first?.transparency = 0.1
        figureNode.geometry?.materials.first?.isDoubleSided = true
        
        if figure == .sphere {
            Points.shared.createPointOnCenter(object: object, node: figureNode)
        } else {
            Points.shared.createPointsOnVertices(object: object, node: figureNode)
        }
        return figureNode
    }
    

    init(type: Figure, image: UIImage, custom: Bool, dimensions: [String: CGFloat] = [:]) {
       // Definition stuff
        self.type = type
        self.objectName = type.rawValue
        self.custom = custom
        self.icon = image
        
        self.objectNode = SCNNode()
        
        if dimensions.isEmpty {
            switch self.type {
                case .cube: self.dimensions = ["Edge": 0.3]
                case .trianglePrism: self.dimensions = ["Edge": 0.6, "Height": 0.5];
                case .rectPrism: self.dimensions = ["Width": 0.3,  "Length": 0.2,  "Height": 0.5];
                case .sphere: self.dimensions = ["Radius": 0.3];
                case .cone: self.dimensions = ["Radius": 0.3, "Height": 0.4];
                case .cuttedCone: self.dimensions = ["Bottom Radius": 0.5,  "Top Radius": 0.2,  "Height": 0.2];
                case .cylinder: self.dimensions = ["Radius": 0.3, "Height": 0.4];
                case .rectPyramid: self.dimensions = ["Width": 0.2, "Length": 0.2, "Height": 0.4];
                case .trianglePyramid: self.dimensions = ["Edge": 0.2, "Height": 0.4];
                case .rightAngledTetrahedron: self.dimensions = ["Catheter1": 0.3, "Catheter2": 0.4, "Height": 0.6]
                case .plane: self.dimensions = ["Width": 0.3, "Length": 0.5];
                case .line: self.dimensions = ["Length": 0.4];
            }
        } else { self.dimensions = dimensions }
        self.currentPosition = float3(0)
        super.init()
        self.objectNode = getFigureNode(type: type, object: self)
        self.addChildNode(objectNode)
    }
    
    required init(original: VirtualObject) {
        type = original.type
        objectName = original.objectName
        custom = original.custom
        icon = original.icon
        objectNode = original.objectNode
        dimensions = original.dimensions
        currentPosition = original.currentPosition
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    func setPosition(object: VirtualObject, newPosition: float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
     
        
        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
        
        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)
            
            // Add the latest position and keep up to 10 recent distances to smooth with.
            recentVirtualObjectDistances.append(hitTestResultDistance)
            recentVirtualObjectDistances = Array(recentVirtualObjectDistances.suffix(10))
            
            let averageDistance = recentVirtualObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }
        
        
        if object.type == .sphere {
            object.simdPosition.y += (Float(object.dimensions["Radius"]!))
        } else if (!object.custom && object.type != .rectPyramid) {
            object.simdPosition.y += ((object.objectNode.boundingSphere.center.y - object.objectNode.boundingBox.min.y))
        }
    }
    
    /// - Tag: AdjustOntoPlaneAnchor
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)
        
        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        
        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
}

extension VirtualObject {
    
  /*  static let availableObjects = [
        // initializing each object as VirtualObject
        VirtualObject(type: .cube, image: #imageLiteral(resourceName: "cubeIcon"), custom: false),
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
        VirtualObject(type: .cube, image: #imageLiteral(resourceName: "lineIcon"), custom: true)] */
    
    /// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
}

extension Collection where Iterator.Element == Float {
    /// Return the mean of a list of Floats. Used with `recentVirtualObjectDistances`.
    var average: Float? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }
        
        return sum / Float(count)
    }
}
