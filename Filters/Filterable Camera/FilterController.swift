//
//  FilterController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 7..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import Foundation
import CoreImage

class FilterController {
    static let shared = FilterController()
    static let componentsList = [
        "CIColorControls",
        "CIExposureAdjust",
        "CIHighlightShadowAdjust",
        "ColorOverlay",
        "CIUnsharpMask",
        "Grain",
        "CIVignette",
        "ChromaticAberration",
        "SelectiveBlur",
    ]
    
    let currentFilterChain = CIFIlterChain()
    
    private init() {
        CustomFiltersConstructor.registerFilters()
        currentFilterChain.components.append(CIFilter(name: "CIColorControls")!)
        currentFilterChain.components.append(CIFilter(name: "CIExposureAdjust")!)
        currentFilterChain.components.append(CIFilter(name: "CIHighlightShadowAdjust")!)
        currentFilterChain.components.append(CIFilter(name: "ColorOverlay")!)
        currentFilterChain.components.append(CIFilter(name: "CIUnsharpMask")!)
    }
}

extension FilterController {
    public enum FilterControllerError: Swift.Error {
        case unknown
    }
}
