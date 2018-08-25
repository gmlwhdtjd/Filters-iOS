//
//  ColorOverlay.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 7. 30..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class ColorOverlay: CIFilter {
    var inputImage: CIImage?
    
    private var inputColor: CIColor = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) 
    
    override var name: String {
        get { return "ColorOverlay" }
        set { }
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Color Overlay",
            kCIAttributeFilterName: "ColorOverlay",
            
            "inputImage": [kCIAttributeClass: "CIImage"],
            
            "inputColor": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIColor",
                           kCIAttributeDisplayName: "inputColor",
                           kCIAttributeDefault: CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
                           kCIAttributeType: kCIAttributeTypeColor],
            
            "outputImage": [kCIAttributeClass: "CIImage"]
        ]
    }
    
    override var inputKeys: [String] {
        get { return ["inputImage", "inputColor"] }
    }
    override var outputKeys: [String] {
        get { return ["outputImage"] }
    }
    
    override func setDefaults() {
        self.inputImage = nil
        self.inputColor = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "inputImage":
            return self.inputImage
        case "inputColor":
            return self.inputColor
        default:
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            self.inputImage = value as? CIImage
        case "inputColor":
            self.inputColor = value as! CIColor
        default:
            super.setValue(value, forKey: key)
        }
    }
    
    override var outputImage: CIImage? {
        guard let cropRect = inputImage?.extent else {
            return nil
        }
        let constantColor = CIFilter(name: "CIConstantColorGenerator")
        constantColor?.setValue(inputColor, forKey: "inputColor")
        
        let blender = CIFilter(name: "CIScreenBlendMode")
        blender?.setValue(constantColor?.outputImage, forKey: "inputImage")
        blender?.setValue(inputImage, forKey: "inputBackgroundImage")
        
        return blender?.outputImage?.cropped(to: cropRect)
    }
}
