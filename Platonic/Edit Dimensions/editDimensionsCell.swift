//
//  editDimensionsCell.swift
//  ShapesAR
//
//  Created by Yersultan Sapar on 8/15/17.
//  Copyright © 2017 Yersultan Sapar. All rights reserved.
//

import UIKit

class editDimensionsCell: UITableViewCell {

    @IBOutlet weak var parameterNameLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    var curValue: Float = 0.1
    
    override func awakeFromNib() {
        super.awakeFromNib()

        parameterNameLabel.minimumScaleFactor = 10 / UIFont.labelFontSize
        parameterNameLabel.adjustsFontSizeToFitWidth = true
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        curValue = valueSlider.value / 100
        valueLabel.text = String(describing: Int(valueSlider.value)) + " cm"
    }
}
