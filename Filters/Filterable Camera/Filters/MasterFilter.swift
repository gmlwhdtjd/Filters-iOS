//
//  MasterFilter.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 7. 18..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class MasterFilter: CIFilter {
    var inputImage: CIImage?
    
    // CIExposureAdjust
    var inputEV: CGFloat = 0.50
    
    // CIHighlightShadowAdjust
    var inputHighlightAmount: CGFloat = 1.00
    var inputShadowAmount: CGFloat = 0.00
    
    // CIColorControls
    var inputSaturation: CGFloat = 1.00
    var inputBrightness: CGFloat = 0.00
    var inputContrast: CGFloat = 1.00
    
    // CIUnsharpMask
    var inputUnsharpMaskRadius: CGFloat = 2.50
    var inputUnsharpMaskIntensity: CGFloat = 0.00
    
    // CIVignette
    var inputVignetteRadius: CGFloat = 1.00
    var inputVignetteIntensity: CGFloat = 0.00
    
    
    override var name: String {
        get { return "MasterFilter" }
        set { }
    }
    override func setDefaults() {
        super.setDefaults()
        
        // CIExposureAdjust
        self.inputEV = 0.50
        
        // CIHighlightShadowAdjust
        self.inputHighlightAmount = 1.00
        self.inputShadowAmount = 0.00
        
        // CIColorControls
        self.inputSaturation = 1.00
        self.inputBrightness = 0.00
        self.inputContrast = 1.00
        
        // CIUnsharpMask
        self.inputUnsharpMaskRadius = 2.50
        self.inputUnsharpMaskIntensity = 0.00
        
        // CIVignette
        self.inputVignetteRadius = 1.00
        self.inputVignetteIntensity = 0.00
    }
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            self.inputImage = value as? CIImage
        case "inputEV":
            self.inputEV = value as! CGFloat
        case "inputHighlightAmount":
            self.inputHighlightAmount = value as! CGFloat
        case "inputShadowAmount":
            self.inputShadowAmount = value as! CGFloat
        case "inputSaturation":
            self.inputSaturation = value as! CGFloat
        case "inputBrightness":
            self.inputBrightness = value as! CGFloat
        case "inputContrast":
            self.inputContrast = value as! CGFloat
        case "inputUnsharpMaskRadius":
            self.inputUnsharpMaskRadius = value as! CGFloat
        case "inputUnsharpMaskIntensity":
            self.inputUnsharpMaskIntensity = value as! CGFloat
        case "inputVignetteRadius":
            self.inputVignetteRadius = value as! CGFloat
        case "inputVignetteIntensity":
            self.inputVignetteIntensity = value as! CGFloat
        default:
            super.setValue(value, forKey: key)
        }
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = self.inputImage else {
            return nil
        }
        
        let exposureAdjustParameters: [String: Any] = [
            "inputImage": inputImage,
            "inputEV": self.inputEV
        ]
        guard let exposureAdjust = CIFilter(name: "CIExposureAdjust", withInputParameters: exposureAdjustParameters),
            let exposureAdjustOutputImage = exposureAdjust.outputImage else {
            return nil
        }
        
        let highlightShadowAdjustParameters: [String: Any] = [
            "inputImage": exposureAdjustOutputImage,
            "inputHighlightAmount": self.inputHighlightAmount,
            "inputShadowAmount": self.inputShadowAmount
        ]
        guard let highlightShadowAdjust = CIFilter(name: "CIHighlightShadowAdjust", withInputParameters: highlightShadowAdjustParameters),
            let highlightShadowAdjustOutputImage = highlightShadowAdjust.outputImage else {
            return nil
        }
        
        let colorControlsParameters: [String: Any] = [
            "inputImage": highlightShadowAdjustOutputImage,
            "inputSaturation": self.inputSaturation,
            "inputBrightness": self.inputBrightness,
            "inputContrast": self.inputContrast
        ]
        guard let colorControls = CIFilter(name: "CIColorControls", withInputParameters: colorControlsParameters),
            let colorControlsOutputImage = colorControls.outputImage else {
                return nil
        }
        
        let unsharpMaskParameters: [String: Any] = [
            "inputImage": colorControlsOutputImage,
            "inputRadius": self.inputUnsharpMaskRadius,
            "inputIntensity": self.inputUnsharpMaskIntensity
        ]
        guard let unsharpMask = CIFilter(name: "CIUnsharpMask", withInputParameters: unsharpMaskParameters),
            let unsharpMaskOutputImage = unsharpMask.outputImage else {
                return nil
        }
        
        let vignetteParameters: [String: Any] = [
            "inputImage": unsharpMaskOutputImage,
            "inputRadius": self.inputVignetteRadius,
            "inputIntensity": self.inputVignetteIntensity
        ]
        guard let vignette = CIFilter(name: "CIVignette", withInputParameters: vignetteParameters),
            let vignetteOutputImage = vignette.outputImage else {
                return nil
        }
        
        return vignetteOutputImage
    }
}
