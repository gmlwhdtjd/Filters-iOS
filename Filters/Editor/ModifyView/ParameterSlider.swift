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
        
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: 53))
        
        self.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with: event) {
            return result
        }
        else {
            let contentViewPoint = self.convert(point, to: contentView)
            if let result = contentView.hitTest(contentViewPoint, with: event) {
                return result
            }
            else {
                return nil
            }
        }
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
        var valueText = ""
        if slider.value < 0 {
            valueText += "-"
        }
        else if slider.value > 0{
            valueText += "+"
        }
        valueText += String(format: "%.02f", abs(slider.value))
        valueLabel.text = valueText
        
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: self.slider.value)
        
        var valueLabelCenterX = thumbRect.minX + thumbRect.width / 2
        let minValueLabelCenterX = titleLabel.frame.maxX + valueLabel.frame.width / 2 + 5
        
        if valueLabelCenterX < minValueLabelCenterX {
            valueLabelCenterX = minValueLabelCenterX
        }
        
        valueLabel.center = CGPoint(x: valueLabelCenterX, y: valueLabel.center.y)
        
        if let callback = self.sliderValueChangedCallback {
            callback(slider.value)
        }
    }
}
