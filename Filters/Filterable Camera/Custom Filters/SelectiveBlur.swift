//
//  SelectiveBlur.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 5..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage
import Foundation

class SelectiveBlur: CIFilter {
    var inputImage: CIImage?

    private var inputPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    private var inputRadius: CGFloat = 1.0
    private var inputIntensity: CGFloat = 0.0
    
    override var name: String {
        get { return "SelectiveBlur" }
        set { }
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Selective Blur",
            kCIAttributeFilterName: "SelectiveBlur",
            
            "inputImage": [kCIAttributeClass: "CIImage"],
            
            "inputPosition": [kCIAttributeClass: "CIVector",
                              kCIAttributeDefault: CIVector(x: 0.5, y: 0.5),
                              kCIAttributeType: kCIAttributeTypePosition],
            
            "inputRadius": [kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: CGFloat(0.0),
                            kCIAttributeIdentity: CGFloat(0.0),
                            kCIAttributeMin: CGFloat(0.0),
                            kCIAttributeSliderMin: CGFloat(0.0),
                            kCIAttributeSliderMax: CGFloat(1.0),
                            kCIAttributeType: kCIAttributeTypeScalar],
        
            "inputIntensity": [kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: CGFloat(0.0),
                               kCIAttributeIdentity: CGFloat(0.0),
                               kCIAttributeMin: CGFloat(0.0),
                               kCIAttributeSliderMin: CGFloat(0.0),
                               kCIAttributeSliderMax: CGFloat(1.0),
                               kCIAttributeType: kCIAttributeTypeScalar],
            
            "outputImage": [kCIAttributeClass: "CIImage"]
        ]
    }
    
    override var inputKeys: [String] {
        get { return ["inputImage", "inputPosition", "inputRadius", "inputIntensity"] }
    }
    override var outputKeys: [String] {
        get { return ["outputImage"] }
    }
    
    override func setDefaults() {
        self.inputImage = nil
        self.inputPosition = CGPoint(x: 0.5, y: 0.5)
        self.inputRadius = 1.0
        self.inputIntensity = 0.0
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "inputImage":
            return self.inputImage
        case "inputPosition":
            return self.inputPosition
        case "inputRadius":
            return self.inputRadius
        case "inputIntensity":
            return self.inputIntensity
        default:
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            self.inputImage = value as? CIImage
        case "inputPosition":
            self.inputPosition = value as! CGPoint
        case "inputRadius":
            self.inputRadius = value as! CGFloat
        case "inputIntensity":
            self.inputIntensity = value as! CGFloat
        default:
            super.setValue(value, forKey: key)
        }
    }
    
    override var outputImage: CIImage? {
        guard let cropRect = inputImage?.extent else {
            return nil
        }
        
        let transform = CGAffineTransform.identity
        
        let affineClamp = CIFilter(name: "CIAffineClamp")
        affineClamp?.setValue(inputImage, forKey: "inputImage")
        affineClamp?.setValue(NSValue(cgAffineTransform: transform), forKey: "inputTransform")
        
        let radialMask = CIFilter(name:"CIGaussianGradient")
        radialMask?.setValue(inputRadius * cropRect.width * 2, forKey: "inputRadius")
        radialMask?.setValue(CIColor(red:0, green:1, blue:0, alpha:0), forKey: "inputColor0")
        radialMask?.setValue(CIColor(red:0, green:1, blue:0, alpha:1), forKey: "inputColor1")
        radialMask?.setValue(CIVector(x: inputPosition.x * cropRect.width, y: inputPosition.y * cropRect.height), forKey: "inputCenter")
        
        let maskedVariableBlur = CIFilter(name: "CIMaskedVariableBlur")
        maskedVariableBlur?.setValue(inputIntensity * cropRect.width / 100, forKey: "inputRadius")
        maskedVariableBlur?.setValue(affineClamp?.outputImage, forKey: "inputImage")
        maskedVariableBlur?.setValue(radialMask?.outputImage, forKey: "inputMask")
        
        return maskedVariableBlur?.outputImage?.cropped(to: cropRect)
    }
}
