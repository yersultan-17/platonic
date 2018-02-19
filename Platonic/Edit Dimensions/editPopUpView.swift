//
//  editPopUpView.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/16/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: UITableViewDataSource {
    
    func setupEditPopUpView() {
        guard let selectedFigureNode = selectedFigureNode else { return }
        if let object = virtualObjectLoader.getVirtualObjectWithNode(node: selectedFigureNode) {
            curParameters = object.getParameters()
            curDimensions = object.dimensions
        }
        var currentFrame = editPopUpView.frame
        if curParameters.count == 1 {
            currentFrame.size.height = 200
            editPopUpView.frame = currentFrame
        }
        if curParameters.count > 1 {
            currentFrame.size.height = 200 + CGFloat(curParameters.count * 82)
            editPopUpView.frame = currentFrame
        }
        parametersTableView.reloadData()
    }
    
    func updateObjectDimensions(object: VirtualObject, newDimensions: [String: CGFloat]) {
        let index = virtualObjectLoader.loadedObjects.index(of: object)
        virtualObjectLoader.removeVirtualObject(at: index!)
        let newObject = VirtualObject(type: object.type, image: object.icon, custom: object.custom, dimensions: newDimensions)
        selectedFigureNode = newObject.objectNode
        print("SELECTED FIGURE IS - \(String(describing: selectedFigureNode?.name))")
        let position = object.currentPosition
        newObject.currentPosition = position
        virtualObjectLoader.loadVirtualObject(newObject, loadedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
              //  self.hideObjectLoadingUI()
                self.placeVirtualObject(loadedObject)
            }
        })
        
       /* if newObject.parent == nil {
            serialQueue.async {
                self.sceneView.scene.rootNode.addChildNode(newObject)
            }
        } */
    }
    
    // MARK: Visual Effect animate functions
    
    func animateIn() {
        setupEditPopUpView()
        self.view.addSubview(editPopUpView)
        editPopUpView.center = self.view.center
        editPopUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        editPopUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.visualEffectView.isHidden = false
            self.editPopUpView.alpha = 1
            self.editPopUpView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.editPopUpView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.editPopUpView.alpha = 0
            self.visualEffectView.effect = nil
            self.visualEffectView.isHidden = true
        }) {(success: Bool) in
            self.editPopUpView.removeFromSuperview()
        }
    }
    
    @IBAction func popUpViewApplyButtonTapped(_ sender: Any) {
        if let selectedNode = selectedFigureNode, let object = virtualObjectLoader.getVirtualObjectWithNode(node: selectedNode) {
            for (index, cell)  in parametersTableView.visibleCells.enumerated() {
                let cell = cell as! editDimensionsCell
                curDimensions[curParameters[index]] = CGFloat(cell.curValue)
            }
            
            updateObjectDimensions(object: object, newDimensions: curDimensions)
        }
        animateOut()
    }
    
    // MARK: Table view configuration
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = parametersTableView.dequeueReusableCell(withIdentifier: "parameterCell", for: indexPath) as! editDimensionsCell
        cell.parameterNameLabel.text = curParameters[indexPath.row] + ":"
        let value = (curDimensions[curParameters[indexPath.row]] ?? 0.1) * 100 // giving default value for nil case
        cell.valueSlider.value = Float(value)
        cell.valueLabel.text = String(describing: Int(value)) + " cm"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curParameters.count
    }
}
