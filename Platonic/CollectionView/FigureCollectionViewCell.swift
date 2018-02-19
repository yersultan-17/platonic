//
//  FigureCollectionViewCell.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/11/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit

class FigureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var figureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.minimumScaleFactor = 10 / UIFont.labelFontSize
        titleLabel.adjustsFontSizeToFitWidth = true
    }
}
