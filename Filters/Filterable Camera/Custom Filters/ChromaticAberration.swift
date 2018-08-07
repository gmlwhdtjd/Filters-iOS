//
//  ChromaticAberration.swift
//  Custom Filters
//
//  Created by Hui Jong Lee on 2018. 8. 6..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import CoreImage

class ChromaticAberration: CIFilter {
    private let kernel: CIKernel
    
    var inputImage: CIImage?
    private var inputIntensity: CGFloat = 0.0;
    
    override var name: String {
        get { return "ChromaticAberration" }
        set { }
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Chromatic Aberration",
            kCIAttributeFilterName: "ChromaticAberration",
            
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
    
    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIKernel(functionName: "chromaticAberrationColor", fromMetalLibraryData: data)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        guard let inputImage = self.inputImage else {
            return nil
        }
        return kernel.apply(extent: inputImage.extent,
                            roiCallback: { index, rect in
                                return rect.insetBy(dx: -10.0, dy: -10.0)
                            } ,
                            arguments: [inputImage, inputIntensity])
    }
}
