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
    
    var componentIndex: Int?
    private var currentComponent: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let index = self.componentIndex,
            index >= 0, index < filterController.currentFilterChain.components.count else {
            return
        }
        
        self.currentComponent = filterController.currentFilterChain.components[index]
        
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
    
    @IBAction func deleteComponent(_ sender: Any) {
        func deleteAndBack() {
            guard let index = self.componentIndex,
                index >= 0, index < filterController.currentFilterChain.components.count else {
                    return
            }
            filterController.currentFilterChain.components.remove(at: index)
            performSegue(withIdentifier: "unwindToFilterRecipeView", sender: self)
        }
        
        let alert = UIAlertController(title: nil, message: "This filter will be deleted from current filter recipe.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Filter", style: .destructive, handler: { _ in
            deleteAndBack()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func backToHome(sender : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
}
