//
//  ColorSlider.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 26..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit
import Hue

class ColorSlider: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var intensitySlider: ParameterSlider!
    @IBOutlet weak var colorSlider: UISlider!
    
    var colorChangedCallback: ((CIColor) -> ())? = nil
    
    private var color: CIColor = CIColor.clear {
        didSet(color) {
            if let callback = self.colorChangedCallback {
                callback(color)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.LoadXib()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.LoadXib()
        self.setup()
    }
    
    private func LoadXib() {
        Bundle.main.loadNibNamed("ColorSlider", owner: self, options: nil)
        
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth]
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 99).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 99).isActive = true
        
        self.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
    }
    
    private func setup() {
        intensitySlider.titleLabel.text = "intensity"
        intensitySlider.slider.minimumValue = 0.0
        intensitySlider.slider.maximumValue = 1.0
        intensitySlider.sliderValueChangedCallback = { value in
            self.color = CIColor(red: self.color.red,
                                        green: self.color.green,
                                        blue: self.color.blue,
                                        alpha: CGFloat(value))
        }
        
        colorSlider.minimumValue = 0.0
        colorSlider.maximumValue = 1.0
    }
}

extension ColorSlider {
    func setColor(_ color: CIColor) {
        let uiColor = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        
        intensitySlider.value = Float(uiColor.alphaComponent)
        colorSlider.value = Float(uiColor.hueComponent)
        self.color = color
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        self.color = CIColor(color: UIColor(hue: CGFloat(colorSlider.value),
                                            saturation: 1.0,
                                            brightness: 0.5,
                                            alpha: self.color.alpha))
    }
}
