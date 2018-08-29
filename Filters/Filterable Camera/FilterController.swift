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
    }
}

extension FilterController {
    public enum FilterControllerError: Swift.Error {
        case unknown
    }
}
