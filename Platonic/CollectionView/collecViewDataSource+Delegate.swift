//
//  collectionViewDataSource.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/11/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Array of objects to select from
   // var availableObjects = [VirtualObject]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return virtualObjectLoader.usingObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FigureCollectionViewCell
//        cell.backgroundColor = UIColor(colorLiteralRed: 74 / 255, green: 144 / 255, blue: 226 / 255, alpha: 0.6)
        cell.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 0.6)
        cell.layer.cornerRadius = 19
        cell.layer.masksToBounds = true
        cell.figureImageView.image = virtualObjectLoader.usingObjects[indexPath.row].icon
        cell.titleLabel.text = virtualObjectLoader.usingObjects[indexPath.row].objectName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = virtualObjectLoader.usingObjects[indexPath.row]
        selectedFigureNode = object.objectNode
        virtualObjectLoader.loadVirtualObject(object, loadedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
             //   self.hideObjectLoadingUI()
                self.placeVirtualObject(loadedObject)
            }
        })

    }
}
