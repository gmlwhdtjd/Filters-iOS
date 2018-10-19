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
            filterChain.components.append(CIFilter(name: component.name, parameters: keyValues)!)
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

extension CIFIlterChain {
    convenience init(withJson json: Data?) throws {
        self.init()
        
        guard let json = json,
            let jsonObject = try JSONSerialization.jsonObject(with: json) as? [[String:Any]] else {
            throw jsonLoadError.cannotConvertJsonToCIFilterChain
        }
        
        for component in jsonObject {
            guard let name = component["name"] as? String else {
                throw jsonLoadError.NameIsMissing
            }
            guard let rowParameters = component["parameters"] as? [[String:Any]] else {
                throw jsonLoadError.ParametersAreMissing
            }
            
            var parameters: [String:Any] = [:]
            
            for rowParameter in rowParameters {
                guard let key = rowParameter["key"] as? String,
                    let type = rowParameter["type"] as? String else {
                    throw jsonLoadError.cannotConvertParameter
                }
                switch type {
                case "CGFloat":
                    guard let value = rowParameter["value"] as? CGFloat else {
                        throw jsonLoadError.cannotConvertParameter
                    }
                    parameters[key] = value
                case "CIColor":
                    guard let red = rowParameter["red"] as? CGFloat,
                        let green = rowParameter["green"] as? CGFloat,
                        let blue = rowParameter["blue"] as? CGFloat,
                        let alpha = rowParameter["alpha"] as? CGFloat else {
                        throw jsonLoadError.cannotConvertParameter
                    }
                    parameters[key] = CIColor(red: red, green: green, blue: blue, alpha: alpha)
                default:
                    break
                }
            }
            
            self.components.append(CIFilter(name: name, parameters: parameters)!)
        }
    }
    
    var json: Data {
        get {
            var rowComponent: [[String:Any]] = []
            
            for component in components {
                var rowParameters: [[String:Any]] = []
                
                let inputKeys = component.inputKeys.filter{ $0 != "inputImage" }
                for (key, value) in component.dictionaryWithValues(forKeys: inputKeys) {
                    var rowParameter: [String:Any] = ["key":key]
                    
                    if let value = value as? CGFloat {
                        rowParameter["type"] = "CGFloat"
                        rowParameter["value"] = value
                    }
                    else if let color = value as? CIColor {
                        rowParameter["type"] = "CIColor"
                        rowParameter["red"] = color.red
                        rowParameter["green"] = color.green
                        rowParameter["blue"] = color.blue
                        rowParameter["alpha"] = color.alpha
                    }
                    else {
                        continue;
                    }
                    
                    rowParameters.append(rowParameter)
                }
                
                let dictionary: [String:Any] = [
                    "name": component.name,
                    "parameters":rowParameters
                ]
                rowComponent.append(dictionary)
            }
            
            return try! JSONSerialization.data(withJSONObject: rowComponent, options: .sortedKeys)
        }
    }
    
    enum jsonLoadError: Error {
        case cannotConvertJsonToCIFilterChain
        case NameIsMissing
        case ParametersAreMissing
        case cannotConvertParameter
    }
}
