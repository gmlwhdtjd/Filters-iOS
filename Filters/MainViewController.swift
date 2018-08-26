//
//  ViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 6. 20..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraPreviewView: UIView!
    
    @IBOutlet weak var cameraSwitchingButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var timerButton: UIButton!
    
    // For camera Animation
    @IBOutlet weak var timerCountLable: UILabel!
    @IBOutlet weak var focusAreaDefaultImage: UIImageView?
    @IBOutlet weak var focusAreaImage: UIImageView!
    @IBOutlet weak var captureEffectView: UIView!
    
    // Preview Constraints
    @IBOutlet weak var cameraViewConstraintAspectNomal: NSLayoutConstraint!
    @IBOutlet weak var cameraViewConstraintAspectSquare: NSLayoutConstraint!
    @IBOutlet weak var cameraViewConstraintAspectWide: NSLayoutConstraint!
    
    var cameraViewConstraintCenterDefualt: NSLayoutConstraint!
    var cameraViewConstraintCenterWide: NSLayoutConstraint!
}

// MARK: - @IBAction & @objc
extension MainViewController {
    @IBAction func switchCameras(_ sender: UIButton) {
        try? cameraController.switchCameras()
    }
    
    @IBAction func changeFlashMode(_ sender: UIButton) {
        switch cameraController.flashMode {
        case .on:
            cameraController.flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        case .off:
            cameraController.flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "Flash Auto Icon"), for: .normal)
        case .auto:
            cameraController.flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    @IBAction func changeAspectRatioMode(_ sender: UIButton) {
        let animateDuration = 0.185
        
        switch cameraController.aspectRatioMode {
        case .normal: // Nomal to Square
            cameraController.aspectRatioMode = .square
            
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectNomal)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectSquare)
        case .square: // Square to Wide
            cameraController.aspectRatioMode = .wide
            
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectSquare)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectWide)
            
            self.view.addConstraint(self.cameraViewConstraintCenterWide)
        case .wide: //Wide to Nomal
            cameraController.aspectRatioMode = .normal
            
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectWide)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectNomal)
            
            self.view.removeConstraint(self.cameraViewConstraintCenterWide)
        }
        
        UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            if $0 { try? self.cameraController.resetPointOfInterest() }
        })
        try? self.cameraController.displayPreview(on: self.cameraPreviewView)
    }
    
    @IBAction func changeTimerMode(_ sender: UIButton) {
        switch cameraController.timerMode {
        case .none:
            cameraController.timerMode = .threeSecond
            timerButton.setImage(#imageLiteral(resourceName: "Timer 3 Icon"), for: .normal)
        case .threeSecond:
            cameraController.timerMode = .fiveSecond
            timerButton.setImage(#imageLiteral(resourceName: "Timer 5 Icon"), for: .normal)
        case .fiveSecond:
            cameraController.timerMode = .tenSecond
            timerButton.setImage(#imageLiteral(resourceName: "Timer 10 Icon"), for: .normal)
        case .tenSecond:
            cameraController.timerMode = .none
            timerButton.setImage(#imageLiteral(resourceName: "Timer 0 Icon"), for: .normal)
        }
    }
    
    @IBAction func setting(_ sender: UIButton) {
        
    }
    
    
    
    @objc func prepareCameraController() {
        cameraController.timerCountLable = self.timerCountLable
        cameraController.focusAreaDefaultImage = self.focusAreaDefaultImage
        cameraController.focusAreaImage = self.focusAreaImage
        cameraController.captureEffectView = self.captureEffectView
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
                return
            }
            self.cameraPreviewView.backgroundColor = nil
            try? self.cameraController.displayPreview(on: self.cameraPreviewView)
            try? self.cameraController.resetPointOfInterest()
        }
    }
    
    @objc func stopCameraController() {
        try? cameraController.stop()
        self.cameraPreviewView.backgroundColor = .black
    }
}

// MARK: - Override member
extension MainViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func configureCameraViewConstraint() {
            // Camera View Constraint Center -> self.view's Constraint & iPhone X has diffrent values
            let viewSize = self.view.frame.size
            var defualtConstant: CGFloat!
            var wideConstant: CGFloat!
            
            if UIDevice.modelName == "iPhone X" || UIDevice.modelName == "Simulator iPhone X" {
                defualtConstant = -48.0
                wideConstant = (viewSize.height - (viewSize.width / 9.0 * 16.0)) / -2.0
            }
            else {
                defualtConstant = (viewSize.height - (viewSize.width / 3.0 * 4.0)) / -2.0
                wideConstant = 0.0
            }
            
            self.cameraViewConstraintCenterDefualt = NSLayoutConstraint(item: self.cameraView, attribute: .centerY,
                                                                        relatedBy: .equal,
                                                                        toItem: self.view, attribute: .centerY,
                                                                        multiplier: 1.0, constant: defualtConstant)
            self.cameraViewConstraintCenterDefualt.priority = .defaultHigh
            
            self.cameraViewConstraintCenterWide =  NSLayoutConstraint(item: self.cameraView, attribute: .centerY,
                                                                      relatedBy: .equal,
                                                                      toItem: self.view, attribute: .centerY,
                                                                      multiplier: 1.0, constant: wideConstant)
            self.cameraViewConstraintCenterWide.priority = .required
            
            self.view.addConstraint(self.cameraViewConstraintCenterDefualt)
        }
        func configureLifecycleNotifications() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(prepareCameraController),
                                                   name: NSNotification.Name.UIApplicationWillEnterForeground,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(stopCameraController),
                                                   name: NSNotification.Name.UIApplicationDidEnterBackground,
                                                   object: nil)
        }
        
        configureCameraViewConstraint()
        configureLifecycleNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareCameraController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopCameraController()
    }
}
