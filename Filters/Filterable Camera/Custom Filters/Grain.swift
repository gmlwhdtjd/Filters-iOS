//
//  Grain.swift
//  Custom Filters
//
//  Created by Hui Jong Lee on 2018. 7. 30..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import Darwin
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
                               kCIAttributeDefault: 0,
                               kCIAttributeIdentity: 0,
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 1,
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
        let transform = randomTransform.translatedBy(x: CGFloat(arc4random_uniform(5000)),y: CGFloat(arc4random_uniform(5000)))
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
