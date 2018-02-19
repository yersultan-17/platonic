//
//  VirtualObject.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/25/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import ARKit


struct VirtualObjectDefinition: Equatable {
    let type: Figure
    let name: String
    let custom: Bool
    var icon = UIImage()
    
    init(type: Figure, image: UIImage, custom: Bool) {
        self.type = type
        self.name = type.rawValue
        self.custom = custom
        self.icon = image
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.type == rhs.type && lhs.name == rhs.name
    }
    
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
}


/* class VirtualObject: SCNNode {
    let definition: VirtualObjectDefinition
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
   
    init(definition: VirtualObjectDefinition, dimensions: [String: CGFloat] = [:]) {
        self.definition = definition
        self.objectNode = SCNNode()
        let type = definition.type
        if dimensions.isEmpty {
            switch type {
                case .cube: self.dimensions = ["Edge": 0.3]
                case .trianglePrism: self.dimensions = ["Edge": 0.6, "Height": 0.5];
                case .rectPrism: self.dimensions = ["Width": 0.3,  "Length": 0.2,  "Height": 0.5];
                case .sphere: self.dimensions = ["Radius": 0.3];
                case .cone: self.dimensions = ["Radius": 0.3, "Height": 0.4];
                case .cuttedCone: self.dimensions = ["Bottom Radius": 0.5,  "Top Radius": 0.2,  "Height": 0.2];
                case .cylinder: self.dimensions = ["Radius": 0.3, "Height": 0.4];
                case .rectPyramid: self.dimensions = ["Width": 0.2, "Length": 0.2, "Height": 0.4];
                case .trianglePyramid: self.dimensions = ["edge": 0.2, "Height": 0.4];
                case .plane: self.dimensions = ["Width": 0.3, "Length": 0.5];
                case .line: self.dimensions = ["Length": 0.4];
            }
        } else {
            self.dimensions = dimensions
        }
        self.currentPosition = float3(0)
        super.init()
        self.objectNode = getFigureNode(type: type, object: self)
        self.addChildNode(objectNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var recentVirtualObjectDistances = [Float]()
} */
