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
    
    var currentCompnentIndex: Int!
    var currentComponent: CIFilter!
    
    var parameterSliders: [ParameterSlider] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentComponent = filterController.currentFilterChain.components[currentCompnentIndex]
        
        let inputKeys = currentComponent.inputKeys.filter{ $0 != "inputImage" }
        let keyValues = currentComponent.dictionaryWithValues(forKeys: inputKeys)
    
        for (key, value) in keyValues {
            if let value = value as? CGFloat {
                let newSlider = ParameterSlider()
                
                newSlider.titleLabel.text = String(key.dropFirst(5))
                newSlider.setSliderValue(Float(value))
                
                if let attrubute = currentComponent.attributes[key] as? [String: Any] {
                    newSlider.slider.minimumValue = Float(attrubute["CIAttributeSliderMin"] as! CGFloat)
                    newSlider.slider.maximumValue = Float(attrubute["CIAttributeSliderMax"] as! CGFloat)
                }
                
                newSlider.sliderValueChangedCallback = { value in
                    self.currentComponent.setValue(CGFloat(value), forKey: key)
                }
                
                parameterSliders.append(newSlider)
                view.addSubview(newSlider)
            }
        }
    }
    
    override func updateViewConstraints() {
        var upperView: UIView = backButton
        
        for parameterSlider in parameterSliders {
            view.addConstraint(NSLayoutConstraint(item: parameterSlider.contentView, attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: upperView, attribute: .bottom,
                                                  multiplier: 1.0, constant: 5.0))
            view.addConstraint(NSLayoutConstraint(item: parameterSlider.contentView, attribute: .left,
                                                  relatedBy: .equal,
                                                  toItem: view, attribute: .left,
                                                  multiplier: 1.0, constant: 15.0))
            view.addConstraint(NSLayoutConstraint(item: parameterSlider.contentView, attribute: .right,
                                                  relatedBy: .equal,
                                                  toItem: view, attribute: .right,
                                                  multiplier: 1.0, constant: -15.0))
            upperView = parameterSlider.contentView
        }
        super.updateViewConstraints()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
