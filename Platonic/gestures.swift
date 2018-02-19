//
//  gestures.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/3/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//
import ARKit
import UIKit

extension ViewController: UIGestureRecognizerDelegate {
    // MARK: - Gestures
    
    func setupRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handletap(from:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        let holdGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdTap(from:)))
        holdGestureRecognizer.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        sceneView.addGestureRecognizer(holdGestureRecognizer)
        
        let gestureVisualEffect = UITapGestureRecognizer(target: self, action: #selector(tapAnimateOut(from:)))
    visualEffectView.addGestureRecognizer(gestureVisualEffect)

    }
    
    @objc func tapAnimateOut(from recognizer: UITapGestureRecognizer) {
        animateOut()
    }
    
    @objc func holdTap(from recognizer: UILongPressGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint)
        if results.count == 0 { return } // return if haven't found anything
        
        guard let result = results.first else { return }
        if recognizer.state == .began {
            if result.node.name == "Line" || result.node.name == "Border" {
                guard let geometry = result.node.geometry else { return }
                if let name = geometry.name, let height = Float(name) {
                    let finalHeight = CGFloat(3 * height / 2)
                    let cyl = SCNCylinder(radius: 0.002, height: finalHeight)
                    result.node.geometry = cyl
                    result.node.geometry?.name = String(describing: finalHeight)
                    result.node.geometry?.materials.first?.diffuse.contents = UIColor.black
                }
            }
        }
    }
    
    @objc func handletap(from recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint)
        if results.count == 0 { return } // return if haven't found anything
        
        guard let result = results.first else { return }
    
        if result.node.name == nil {
            print("TAP ON FIGURE TO PLACE IT")
        }
        if result.node.parent?.parent == sceneView.scene.rootNode {
            print("SELECTED FIGURE IS - \(String(describing: result.node.name))")
            selectedFigureNode = result.node
            selectedObject = virtualObjectLoader.getVirtualObjectWithNode(node: result.node)
        }
    
        guard let curObject = selectedObject else { return }
        
        if result.node.name == "Line" || result.node.name == "Border" {
            if drawParallelModeIsEnabled {
                for line in curObject.lines {
                    if line.node == result.node {
                        if (parallelToLineNode != nil && parallelToLineNode == line.node) {
                            parallelToLineNode = nil
                            parallelToLine = nil
                            result.node.geometry?.materials.first?.diffuse.contents = UIColor.black
                        } else {
                            parallelToLineNode = line.node
                            parallelToLine = line
                            
                            
                            let (aNormal, aPoint) = line.getParametricEquation()
                            
                            let (p1, p2, p3) = aNormal.getComponents()
                            let (x0, y0, z0) = aPoint.getComponents()
                            
                            print("FOR PARALLEL DRAWING YOU HAVE CHOSEN THE FOLLOWING LINE")
                            print("x = \(p1)s + \(x0)")
                            print("y = \(p2)s + \(y0)")
                            print("z = \(p3)s + \(z0)")
                            
                            
                            result.node.geometry?.materials.first?.diffuse.contents = UIColor.green
                        }
                        break
                    }
                }
                
                
            } else if linesIntersectionModeIsEnabled {
                var curLine: Line?
                for line in curObject.lines {
                    if line.node == result.node {
                        curLine = line
                        break
                    }
                }
                if intersectionLines.contains(where: { $0 == curLine! }) {
                    intersectionLines.removeLast()
                    result.node.geometry?.materials.first?.diffuse.contents = UIColor.black
                } else {
                    intersectionLines.append(curLine!)
                    result.node.geometry?.materials.first?.diffuse.contents = UIColor.green
                }
                if intersectionLines.count == 2 {
                    let firstLine = intersectionLines[0]
                    let secondLine = intersectionLines[1]
                    
                    guard let intersection = Calculations.shared.getIntersectionUpdated(aLine: firstLine, bLine: secondLine) else { finishIntersectingLines(); return }
                    print("Forced intersection")
                    
                    let figureNode = result.node.parent!
                    let pointNode = Points.shared.createPoint()
                    pointNode.name = "Point"
                    pointNode.position = intersection
                    pointNode.geometry?.materials.first?.diffuse.contents = UIColor.yellow
                    
                    var adjustPointOnFirstLine = SCNVector3()
                    var adjustPointOnSecondLine = SCNVector3()
                    
                    let distToFirstStart = Calculations.shared.getDistance(from: intersection, to: firstLine.longStartPoint)
                    let distToFirstEnd = Calculations.shared.getDistance(from: intersection, to: firstLine.longEndPoint)
                    
                    let distToSecondStart = Calculations.shared.getDistance(from: intersection, to: secondLine.longStartPoint)
                    let distToSecondEnd = Calculations.shared.getDistance(from: intersection, to: secondLine.longEndPoint)
                    
                    if (distToSecondStart + distToSecondEnd == secondLine.longLength || distToFirstStart + distToFirstEnd == firstLine.longLength) {
                    
                    } else {
                        switch distToFirstStart > distToFirstEnd {
                            case true: adjustPointOnFirstLine = firstLine.longStartPoint
                            case false: adjustPointOnFirstLine = firstLine.longEndPoint
                        }
                        
                        switch distToSecondStart > distToSecondEnd {
                            case true: adjustPointOnSecondLine = secondLine.longStartPoint
                            case false: adjustPointOnSecondLine = secondLine.longEndPoint
                        }
                   
                        Lines.shared.adjustLineNode(node: firstLine.node, startPoint: intersection, endPoint: adjustPointOnFirstLine)
                        Lines.shared.adjustLineNode(node: secondLine.node, startPoint: intersection, endPoint: adjustPointOnSecondLine)
                        
                        for (index, line) in curObject.lines.enumerated() {
                            if line.node == firstLine.node {
                                curObject.lines[index].longStartPoint = intersection
                                curObject.lines[index].longEndPoint = adjustPointOnFirstLine
                                curObject.lines[index].longLength = Calculations.shared.getDistance(from: intersection, to: adjustPointOnFirstLine)
                            } else if line.node == secondLine.node {
                                curObject.lines[index].longStartPoint = intersection
                                curObject.lines[index].longEndPoint = adjustPointOnSecondLine
                                curObject.lines[index].longLength = Calculations.shared.getDistance(from: intersection, to: adjustPointOnSecondLine)
                            }
                        }
                    }
                    
                    figureNode.addChildNode(pointNode)
                    finishIntersectingLines()
                }
            } else {
                let pointNode = Points.shared.createPoint()
                pointNode.eulerAngles = result.node.eulerAngles
                pointNode.position = result.localCoordinates
                pointNode.position.x = 0
                pointNode.position.z = 0
                
                result.node.addChildNode(pointNode)
                curObject.points.append(pointNode)
            }
        }
        
        
        if result.node.name == "Point" || result.node.name == "vertexPoint" { // if we tapped on the point
            if drawParallelModeIsEnabled {
               var figureNode = SCNNode()
                if result.node.parent?.name == "Border" || result.node.parent?.name == "Line" {
                    figureNode = (result.node.parent?.parent)!
                } else {
                    figureNode = (result.node.parent)!
                }
                pointOnTheParallel = result.node
                var nodePos = result.node.position
                if result.node.parent?.name == "Border" || result.node.parent?.name == "Line" {
                    nodePos = (result.node.parent?.convertPosition(nodePos, to: result.node.parent?.parent))!
                }
                
                print("THE POINT YOU HAVE CHOSEN FOR PARALLEL LINE DRAWING")
                print("Coords - \(nodePos)")
                
                guard let parallelToLine = parallelToLine else { finishParallelDrawing(); return }
                
                let (_, p, _, q, _, r) = Lines.shared.getCanonicEqOfParallelLine(to: parallelToLine, through: nodePos)
                
                print("YOUR SUPPOSED PARALLEL LINE IS")
                print("x = \(p)t + \(nodePos.x)")
                print("x = \(q)t + \(nodePos.y)")
                print("x = \(r)t + \(nodePos.z)")

                
                let normalOfParallel = SCNVector3(p,q,r)
                let pointNode = Points.shared.createPoint()
                var success = false
                for line in curObject.lines {
                  //  if Lines.shared.linesAreCollinearForParallel(aNormal: normalOfParallel, bLine: line) { continue }
                  //  print("Lines are not collinear")
                    guard let intersection = Calculations.shared.getIntersectionForParallel(aPoint: nodePos, aNormal: normalOfParallel, bLine: line) else { continue }
                    
                    print("We can intersect lines for parallel!")
                    pointNode.position = intersection
                    pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                    figureNode.addChildNode(pointNode)
                    
                    var flag = false
                    for point in curObject.points {
                        let dist = Calculations.shared.getDistance(from: point.worldPosition, to: pointNode.worldPosition)
                        if (dist < 0.01) { flag = true; break }
                    }
                    let distToStart = Calculations.shared.getDistance(from: pointNode.position, to: line.longStartPoint)
                    let distToEnd = Calculations.shared.getDistance(from: pointNode.position, to: line.longEndPoint)
                    
                    if (flag || distToStart + distToEnd != line.longLength) { print("Removing point"); pointNode.removeFromParentNode() } else {   print("We add a point")
                            curObject.points.append(pointNode)
                            success = true
                            break
                        }
                }
                if success {
                    let lineNode = Lines.shared.createLineNode(from: nodePos, to: pointNode.position)
                    figureNode.addChildNode(lineNode)
                    let newLine = Line(node: lineNode, startPoint: nodePos, endPoint: pointNode.position)
                    curObject.lines.append(newLine)
                }
                finishParallelDrawing()
            
            } else if lineDrawModeIsEnabled {
                var nodePos = result.node.position
                if result.node.parent?.name == "Border" || result.node.parent?.name == "Line" {
                    // convert position to figureNode's coordinate system if the point's parent is not figureNode
                    nodePos = (result.node.parent?.convertPosition(nodePos, to: result.node.parent?.parent))!
                }
                twoPointsNodes.append(result.node)
                twoPointsPos.append(nodePos)
                
                result.node.geometry?.materials.first?.diffuse.contents = UIColor.green // highlight with green
                
                if twoPointsNodes.count == 2 { // we are going to draw a line using selected points
                    let startPoint = twoPointsPos[0]
                    let endPoint = twoPointsPos[1]
                    
                    let startNode = twoPointsNodes[0]
                    let endNode = twoPointsNodes[1]
                    if checkPointsLineDrawing(startNode: startNode, endNode: endNode, startPoint: startPoint, endPoint: endPoint) == false {
                        print("Points are unappropriate")
                        finishLineDrawing()
                    } else {
                        let lineNode = Lines.shared.createLineNode(from: startPoint, to: endPoint)
                        var figureNode = SCNNode()
                        if result.node.parent?.name == "Border" || result.node.parent?.name == "Line" {
                            figureNode = (result.node.parent?.parent)!
                        } else {
                            figureNode = (result.node.parent)!
                        }
                        figureNode.addChildNode(lineNode)
                        
                        let newLine = Line(node: lineNode, startPoint: startPoint, endPoint: endPoint)
                        for line in curObject.lines {
                            if Lines.shared.linesAreCollinear(aLine: newLine, bLine: line) { continue }
                            print("Lines are not collinear")
                            guard let intersection = Calculations.shared.getIntersectionUpdated(aLine: newLine, bLine: line) else { continue }
                            
                            print("We can intersect lines")
                            let pointNode = Points.shared.createPoint()
                            pointNode.position = intersection
                            pointNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
                            figureNode.addChildNode(pointNode)
                            
                            var flag = false
                            for point in curObject.points {
                                let dist = Calculations.shared.getDistance(from: point.worldPosition, to: pointNode.worldPosition)
                                if (dist < 0.01) { flag = true; break }
                            }
                            let distToStart = Calculations.shared.getDistance(from: pointNode.position, to: line.longStartPoint)
                            let distToEnd = Calculations.shared.getDistance(from: pointNode.position, to: line.longEndPoint)
        
                            if (flag || distToStart + distToEnd != line.longLength) { print("Removing point"); pointNode.removeFromParentNode() } else { print("We add a point"); curObject.points.append(pointNode) }
                        }
                        curObject.lines.append(newLine)
                        finishLineDrawing()
                    }
                }
            } else if crossSectionModeIsEnabled { 
                var nodePos = result.node.position
                applyButtonResult = result
                if result.node.parent?.name == "Border" || result.node.parent?.name == "Line" {
                    nodePos = (result.node.parent?.convertPosition(nodePos, to: result.node.parent?.parent))!
                }
                if crossSectionPoints.contains(where: {$0.0 == result.node && $0.1 == nodePos}) {
                    result.node.geometry?.materials.first?.diffuse.contents = UIColor.black
                    crossSectionPoints = crossSectionPoints.filter { $0.0 != result.node && $0.1 != nodePos }
                } else {
                    crossSectionPoints.append((result.node, nodePos))
                }
                result.node.geometry?.materials.first?.diffuse.contents = UIColor.orange
            } else {
                Points.shared.highlightPoint(node: result.node)
            }
        }
    }

}
