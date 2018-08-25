//
//  CustomFiltersConstructor.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 9..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class CustomFiltersConstructor: CIFilterConstructor {
    static func registerFilters() {
        CIFilter.registerName("ColorOverlay",
                              constructor: CustomFiltersConstructor(),
                              classAttributes: [kCIAttributeFilterCategories: ["Custom Filters"]])
        CIFilter.registerName("Grain",
                              constructor: CustomFiltersConstructor(),
                              classAttributes: [kCIAttributeFilterCategories: ["Custom Filters"]])
        CIFilter.registerName("SelectiveBlur",
                              constructor: CustomFiltersConstructor(),
                              classAttributes: [kCIAttributeFilterCategories: ["Custom Filters"]])
        CIFilter.registerName("ChromaticAberration",
                              constructor: CustomFiltersConstructor(),
                              classAttributes: [kCIAttributeFilterCategories: ["Custom Filters"]])
    }
    
    func filter(withName name: String) -> CIFilter? {
        switch name {
        case "ColorOverlay":
            return ColorOverlay()
        case "Grain":
            return Grain()
        case "SelectiveBlur":
            return SelectiveBlur()
        case "ChromaticAberration":
            return ChromaticAberration()
        default:
            return nil
        }
    }
}
