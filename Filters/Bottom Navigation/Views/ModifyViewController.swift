//
//  ModifyViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 21..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class ModifyViewController: UIViewController {

    let filterController = FilterController.shared
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var modifyerStackView: UIStackView!
    
    var currentComponent: CIFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.backToHome))
        self.view.addGestureRecognizer(gesture)
        
        guard let currentComponent = self.currentComponent else {
            return
        }
        
        let inputKeys = currentComponent.inputKeys.filter{ $0 != "inputImage" }
        let keyValues = currentComponent.dictionaryWithValues(forKeys: inputKeys)
    
        for (key, value) in keyValues {
            if let value = value as? CGFloat {
                let parameterSlider = ParameterSlider()
                
                parameterSlider.titleLabel.text = String(key.dropFirst(5))
                parameterSlider.value = Float(value)
                
                if let attrubute = currentComponent.attributes[key] as? [String: Any] {
                    parameterSlider.slider.minimumValue = Float(attrubute["CIAttributeSliderMin"] as! CGFloat)
                    parameterSlider.slider.maximumValue = Float(attrubute["CIAttributeSliderMax"] as! CGFloat)
                }
                
                parameterSlider.sliderValueChangedCallback = { value in
                    self.currentComponent?.setValue(CGFloat(value), forKey: key)
                }
                
                modifyerStackView.addArrangedSubview(parameterSlider)
            }
            else if let color = value as? CIColor {
                let colorSlider = ColorSlider()
                
                colorSlider.setColor(color)
                colorSlider.colorChangedCallback = { color in
                    self.currentComponent?.setValue(color, forKey: key)
                }
                
                modifyerStackView.addArrangedSubview(colorSlider)
            }
        }
    }
    
    @objc func backToHome(sender : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
}
