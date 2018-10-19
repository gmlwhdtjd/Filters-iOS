//
//  Grain.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 7. 30..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class Grain: CIFilter {
    var inputImage: CIImage?
    
    private var inputIntensity: CGFloat = 0.0
    
    override var name: String {
        get { return "Grain" }
        set { }
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Grain",
            kCIAttributeFilterName: "Grain",
            
            "inputImage": [kCIAttributeClass: "CIImage"],
            
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
        get { return ["inputImage", "inputIntensity"] }
    }
    override var outputKeys: [String] {
        get { return ["outputImage"] }
    }
    
    override func setDefaults() {
        self.inputImage = nil
        self.inputIntensity = 0.0
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "inputImage":
            return self.inputImage
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
        let random = CIFilter(name: "CIRandomGenerator")
        let randomTransform = CGAffineTransform(scaleX: cropRect.width / 1500, y: cropRect.width / 1500)
        let transform = randomTransform.translatedBy(x: CGFloat.random(in: 0 ..< 5000),y: CGFloat.random(in: 0 ..< 5000))
        let randomImage = random?.outputImage?.transformed(by: transform)
        
        let alphaMatrix = CIFilter(name:"CIColorMatrix")
        alphaMatrix?.setValue(CIVector(x: 0.0, y: 0.0, z: 0.0, w: inputIntensity / 4.0), forKey:"inputAVector")
        alphaMatrix?.setValue(randomImage, forKey: "inputImage")
        
        let blender = CIFilter(name: "CIColorBurnBlendMode")
        blender?.setValue(alphaMatrix?.outputImage, forKey: "inputImage")
        blender?.setValue(inputImage, forKey: "inputBackgroundImage")
        
        return blender?.outputImage?.cropped(to: cropRect)
    }
}
