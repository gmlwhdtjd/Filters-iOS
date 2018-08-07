//
//  CIFilterChain.swift
//  Filterable Camera
//
//  Created by Hui Jong Lee on 2018. 7. 30..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class CIFIlterChain {
    var inputImage: CIImage?
    
    private var filters: [CIFilter]
    
    init() {
        filters = []
    }

    final func addFilter(_ filter: CIFilter) {
        filters.append(filter)
    }
    final func addFilter(_ filterChain: CIFIlterChain)  {
        filters.append(contentsOf: filterChain.filters)
    }
    final func addFilter(name: String) {
        guard let newFilter = CIFilter(name: name) else {
            return
        }
        
        filters.append(newFilter)
    }
    
    final func setValueOfLastFilter(_ value: Any?, forKey key: String) {
        filters.last?.setValue(value, forKey: key)
    }
    
    final var outputImage: CIImage? {
        guard let firstFilter = filters.first else {  // Passthought
            return inputImage
        }
        
        // Some filter doesn't have inputImage, and user can use it for first filter
        if firstFilter.inputKeys.contains("inputImage") {
            filters.first?.setValue(inputImage, forKey: "inputImage")
        }
        
        for i in 0..<filters.count - 1 {
            filters[i + 1].setValue(filters[i].outputImage, forKey: "inputImage")
        }
        
        return filters.last?.outputImage ?? inputImage
    }
}
