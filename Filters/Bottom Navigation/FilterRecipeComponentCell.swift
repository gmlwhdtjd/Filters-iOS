//
//  FilterRecipeComponentCell.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 13..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class FilterRecipeComponentCell: UICollectionViewCell {
    
    var filterName: String? {
        didSet {
            switch filterName {
            case "CIExposureAdjust":
                componentLabel.text = "Exposure"
            case "CIHighlightShadowAdjust":
                componentLabel.text = "Tone"
            case "CIColorControls":
                componentLabel.text = "Basic"
            case "CIUnsharpMask":
                componentLabel.text = "Sharpen"
            case "CIVignette":
                componentLabel.text = "Vignette"
            case "ColorOverlay":
                componentLabel.text = "Color"
            case "Grain":
                componentLabel.text = "Grain"
            case "ChromaticAberration":
                componentLabel.text = "Color Distortion"
            case "SelectiveBlur":
                componentLabel.text = "Blur"
            default:
                componentLabel.text = nil
            }
        }
    }
    
    @IBOutlet private weak var componentLabel: UILabel!
    
    override func prepareForReuse() {
        self.componentLabel.text = ""
//        self.componentButton.imageView?.image = nil
    }
}
