//
//  CIFilterChain.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 7. 30..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class CIFIlterChain: CIFilter {
    var inputImage: CIImage?
    
    var components: [CIFilter] = []
    
    override var inputKeys: [String] {
        get { return ["inputImage"] }
    }
    override var outputKeys: [String] {
        get { return ["outputImage"] }
    }
    
    override func setDefaults() {
        self.inputImage = nil
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "inputImage":
            return self.inputImage
        default:
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            self.inputImage = value as? CIImage
        default:
            super.setValue(value, forKey: key)
        }
    }
    
    override func copy() -> Any {
        let filterChain = CIFIlterChain()
        
        for component in components {
            let inputKeys = component.inputKeys.filter{ $0 != "inputImage" }
            let keyValues = component.dictionaryWithValues(forKeys: inputKeys)
            filterChain.components.append(CIFilter(name: component.name, withInputParameters: keyValues)!)
        }
        
        return filterChain
    }
    
    override var outputImage: CIImage? {
        guard let firstFilter = components.first else {  // Pass throught
            return inputImage
        }
        
        // Some filter doesn't have inputImage, and user can use it for first filter
        if firstFilter.inputKeys.contains("inputImage") {
            components.first?.setValue(inputImage, forKey: "inputImage")
        }
        
        for i in 0..<components.count - 1 {
            components[i + 1].setValue(components[i].outputImage, forKey: "inputImage")
        }
        
        return components.last?.outputImage ?? inputImage
    }
}
