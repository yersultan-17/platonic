//
//  ViewController.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/20/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import OpenGLES

class ViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var session: ARSession {
        return sceneView.session
    }
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "queue")
    
    var focusSquare = FocusSquare()
    
    // MARK: Visual effect
    
    var effect: UIVisualEffect!
    
    // MARK: Selected figure
    
    var selectedFigureNode: SCNNode?
    var selectedObject: VirtualObject?
    var curParameters = [String]()
    var curDimensions = [String: CGFloat]()
    
    // MARK: Data for lines intersection
    
    var intersectionLines = [Line]()
    
    // MARK: Data for user line drawing
    
    var twoPointsNodes = [SCNNode]()
    var twoPointsPos = [SCNVector3]()
    
    // MARK: Data for cross-section drawing
    
    var crossSectionPoints = [(SCNNode, SCNVector3)]()
    var applyButtonResult = SCNHitTestResult()
    
    // MARK: Data for parallel line drawing
    
    var pointOnTheParallel = SCNNode()
    var parallelToLineNode: SCNNode?
    var parallelToLine: Line?
    
    // MARK: - Other properties
    
    var restartExperienceButtonIsEnabled = true
    var lineDrawModeIsEnabled = false
    var crossSectionModeIsEnabled = false
    var linesIntersectionModeIsEnabled = false
    var drawParallelModeIsEnabled = false
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?

    @IBOutlet weak var editPopUpView: UIView!
    @IBOutlet weak var parametersTableView: UITableView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var sceneView: VirtualObjectARView!
    @IBOutlet weak var figuresCollectionView: UICollectionView!
    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var toolBarView: UIView!
    

    var restartExperienceHandler: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        virtualObjectLoader.getAvailableFigures()

        
        setupRecognizers()
    
        figuresCollectionView.delegate = self
        figuresCollectionView.dataSource = self
        parametersTableView.dataSource = self
       
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        editPopUpView.layer.cornerRadius = 5
        
        toolBarView.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the 'ARSession'
        resetTracking()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
       // statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    // MARK: - Intersecting lines
    
    func finishIntersectingLines() {
        for line in intersectionLines {
            line.node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        }
        intersectionLines.removeAll()
    }
    
    // MARK: - Parallel line drawing
    
    func finishParallelDrawing() {
        if let parallelToLineNode = parallelToLineNode {
            parallelToLineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        }
        pointOnTheParallel = SCNNode()
        parallelToLineNode = nil
        parallelToLine = nil
        drawParallelModeIsEnabled = false
    }
    
    // MARK: - Cross-section drawing
    
    func checkPointsCrossSection(points: [SCNVector3]) -> Bool {
        if points.count <= 2 { return false }
        return true
    }
    
    func finishCrossSectionDrawing() {
        for (pointNode, _) in crossSectionPoints {
            pointNode.geometry?.materials.first?.diffuse.contents = UIColor.black
        }
        crossSectionPoints.removeAll()
    }
    
    
    // MARK: - Line drawing
    
    func checkPointsLineDrawing(startNode: SCNNode, endNode: SCNNode, startPoint: SCNVector3, endPoint: SCNVector3) -> Bool {
        guard let object = selectedObject else { return false }
        if startPoint == endPoint { return false } // check for equality of two points
        
        // line already exists with these two points
        if Lines.shared.getLineNodeWithPoints(object: object, startPoint: startPoint, endPoint: endPoint) != nil { return false }
        if Lines.shared.getLineNodeWithPoints(object: object, startPoint: endPoint, endPoint: startPoint) != nil { return false }
        
        // we cannot create a line with points on a existing line
        if ((startNode.parent?.name == "Line" || startNode.parent?.name == "Border") && (endNode.parent?.name == "Line" || endNode.parent?.name == "Border")) {
            if startNode.parent == endNode.parent  { return false }
        }
        
        // we cannot create a line with vertexPoint and a point on the line, which edge is this vertexPoint
        var edgePoint: SCNVector3?
        var checkNode: SCNNode?
        if startNode.name == "vertexPoint" && endNode.name != "vertexPoint" { edgePoint = startPoint; checkNode = endNode }
        if startNode.name != "vertexPoint" && endNode.name == "vertexPoint" { edgePoint = endPoint; checkNode = startNode }
        
        guard let edge = edgePoint else { return true }
        
        let lineNodes = Lines.shared.getLineNodesWithEgde(object: object, edge: edge)
        if !lineNodes.isEmpty {
            for lineNode in lineNodes {
                if lineNode == checkNode!.parent { return false }
            }
        }
        
        // everything is ok, so we allow to draw a line
        return true
    }
    
    func finishLineDrawing() {
        for point in twoPointsNodes { // back to black color
            point.geometry?.materials.first?.diffuse.contents = UIColor.black
        }
        twoPointsNodes = []
        twoPointsPos = []
    }
    
    // MARK: - Focus Square business
    
    func updateFocusSquare() {
        let isObjectVisible = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
          //  statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // We should always have a valid world position unless the sceen is just being initialized.
        guard let (worldPosition, planeAnchor, _) = sceneView.worldPosition(fromScreenPosition: screenCenter, objectPosition: focusSquare.lastPosition) else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
        //    addObjectButton.isHidden = true
            return
        }
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
            let camera = self.session.currentFrame?.camera
            
            if let planeAnchor = planeAnchor {
                self.focusSquare.state = .planeDetected(anchorPosition: worldPosition, planeAnchor: planeAnchor, camera: camera)
            } else {
                self.focusSquare.state = .featuresDetected(anchorPosition: worldPosition, camera: camera)
            }
        }
   //     addObjectButton.isHidden = false
    //    statusViewController.cancelScheduledMessage(for: .focusSquare)
    }
    
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
     //   blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
         //   self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}


