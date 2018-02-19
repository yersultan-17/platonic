//
//  popoverActions.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 7/26/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import SceneKit

extension ViewController {
    
    enum SegueIdentifier: String {
        case showObjects
        case showSettings
    }
    
    @IBAction func settingsButtonTapped(_ button: UIButton) {
        guard selectedFigureNode != nil else { return }
        animateIn()
    }
    
    @IBAction func drawParallelButtonTapped(_ sender: Any) {
        if drawParallelModeIsEnabled {
            finishParallelDrawing()
        } else {
            
        }
        linesIntersectionModeIsEnabled = false
        lineDrawModeIsEnabled = false
        crossSectionModeIsEnabled = false
        drawParallelModeIsEnabled = !drawParallelModeIsEnabled
    }
    
    @IBAction func linesIntersectionButtonTapped(_ sender: Any) {
        if linesIntersectionModeIsEnabled {
            finishIntersectingLines()
           // linesIntersectionButton.setTitleColor(UIColor.red, for: .normal)
        } else {
          //  linesIntersectionButton.setTitleColor(UIColor.green, for: .normal)
        }
        linesIntersectionModeIsEnabled = !linesIntersectionModeIsEnabled
        lineDrawModeIsEnabled = false
        drawParallelModeIsEnabled = false
        crossSectionModeIsEnabled = false
    }
    
    @IBAction func lineDrawButtonTapped(_ sender: Any) {
        if lineDrawModeIsEnabled {
            finishLineDrawing()
         //   lineDrawModeButton.setTitleColor(UIColor.red, for: .normal)
        } else {
         //   lineDrawModeButton.setTitleColor(UIColor.green, for: .normal)
        }
        finishCrossSectionDrawing()
        crossSectionModeIsEnabled = false
    //    crossSectionModeButton.setTitleColor(UIColor.red, for: .normal)
        lineDrawModeIsEnabled = !lineDrawModeIsEnabled
    }
    
    @IBAction func crossSectionButtonTapped(_ sender: Any) {
        if crossSectionModeIsEnabled {
            var points = [SCNVector3]()
            for point in crossSectionPoints {
                points.append(point.1)
            }
            if checkPointsCrossSection(points: points) {
                let crossSectionNode = CrossSection.shared.getCrossSection(points: points)
                var figureNode = SCNNode()
                if applyButtonResult.node.parent?.name == "Border" || applyButtonResult.node.parent?.name == "Line" {
                    figureNode = (applyButtonResult.node.parent?.parent)!
                } else {
                    figureNode = applyButtonResult.node.parent!
                }
                
                figureNode.addChildNode(crossSectionNode)
                
            }
            finishCrossSectionDrawing()
          //  crossSectionModeButton.setTitleColor(UIColor.red, for: .normal)
        } else {
            //  crossSectionModeButton.setTitleColor(UIColor.green, for: .normal)
        }
        finishLineDrawing()
        lineDrawModeIsEnabled = false
    
      //  lineDrawModeButton.setTitleColor(UIColor.red, for: .normal)
        crossSectionModeIsEnabled = !crossSectionModeIsEnabled
    }
    


    @IBAction func restartExperience(_ sender: Any) {
        // we need there handler function
        crossSectionModeIsEnabled = true
        crossSectionButtonTapped(self)
        linesIntersectionModeIsEnabled = true
        linesIntersectionButtonTapped(self)
        restartExperience()
    }
    
    // MARK: Restart Experience function
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false
        
   //     statusViewController.cancelAllScheduledMessages()
        
        virtualObjectLoader.removeAllVirtualObjects()
      //  addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
     //   addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }

}
