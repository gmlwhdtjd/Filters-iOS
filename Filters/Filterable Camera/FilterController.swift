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
    
    let sampleFilterWithInfo: [String : Any] = [
        "name": "sample",
        "FilterRecipe": [
            ["name": "CIExposureAdjust",
             "parameters": ["inputEV": 0.50]],
            ["name": "CIHighlightShadowAdjust",
             "parameters": ["inputHighlightAmount" : 1.00,
                            "inputShadowAmount": 0.00]],
            ["name": "CIColorControls",
             "parameters": ["inputSaturation" : 1.00,
                            "inputBrightness": 0.00,
                            "inputContrast": 1.00]],
            ["name": "CIUnsharpMask",
             "parameters": ["inputRadius" : 2.50,
                            "inputIntensity": 0.00]],
            ["name": "CIVignette",
             "parameters": ["inputRadius" : 0.50,
                            "inputIntensity": 2.00]],
            ["name": "ColorOverlay",
             "parameters": ["inputColor" : ["red": 0.0,
                                            "green": 0.5,
                                            "blue": 0.0,
                                            "alpha": 0.3]]],
            ["name": "Grain",
             "parameters": ["inputIntensity": 1.00]],
            ["name": "ChromaticAberration",
             "parameters": ["inputIntensity": 0.00]],
            ["name": "SelectiveBlur",
             "parameters": ["inputRadius" : 0.50,
                            "inputIntensity": 0.20]],
        ]
    ]
    
    let currentFilterChain = CIFIlterChain()
    
    private init() {
        CustomFiltersConstructor.registerFilters()
        currentFilterChain.components.append(CIFilter(name: "CIExposureAdjust")!)
        currentFilterChain.components.append(CIFilter(name: "CIHighlightShadowAdjust")!)
        currentFilterChain.components.append(CIFilter(name: "CIColorControls")!)
        currentFilterChain.components.append(CIFilter(name: "CIUnsharpMask")!)
        currentFilterChain.components.append(CIFilter(name: "CIVignette")!)
        let color = CIFilter(name: "ColorOverlay")!
        color.setValue(CIColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 0.1), forKey: "inputColor")
        currentFilterChain.components.append(color)
        currentFilterChain.components.append(CIFilter(name: "Grain")!)
        currentFilterChain.components.append(CIFilter(name: "ChromaticAberration")!)
        currentFilterChain.components.append(CIFilter(name: "SelectiveBlur")!)
    }
}

extension FilterController {
    public enum FilterControllerError: Swift.Error {
        case unknown
    }
}
