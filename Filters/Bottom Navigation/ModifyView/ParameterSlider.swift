//
//  ParameterSlider.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 22..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class ParameterSlider: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var sliderValueChangedCallback: ((Float) -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.LoadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.LoadXib()
    }
    
    private func LoadXib() {
        Bundle.main.loadNibNamed("ParameterSlider", owner: self, options: nil)
        
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth]
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 53).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 53).isActive = true
        
        self.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
    }
}

extension ParameterSlider {
    func setSliderValue(_ value: Float) {
        DispatchQueue.main.async {
            self.slider.value = value
            self.sliderValueChanged(self)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: self.slider.value)
        
        let valueLabelCenterX = thumbRect.minX + thumbRect.width / 2
        let minValueLabelCenterX = titleLabel.frame.maxX + valueLabel.frame.width / 2 + 5
        
        valueLabel.center = CGPoint(x: valueLabelCenterX > minValueLabelCenterX ? valueLabelCenterX : minValueLabelCenterX, y: valueLabel.center.y)
        valueLabel.text = (slider.value == 0 ? "" : (slider.value > 0 ? "+" : "-")) + String(format: "%.02f", abs(slider.value))
        
        if let callback = self.sliderValueChangedCallback {
            callback(slider.value)
        }
    }
}
