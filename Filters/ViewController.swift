//
//  ViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 6. 20..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    let cameraController = CameraController()
    let uiImagePicker = UIImagePickerController()
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var cameraPreviewView: UIView!
    
    @IBOutlet weak var cameraSwitchingButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var timerButton: UIButton!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var innerCaptureImage: UIImageView!
    
    // For camera Animation
    @IBOutlet weak var timerCountLable: UILabel!
    @IBOutlet weak var focusAreaDefaultImage: UIImageView?
    @IBOutlet weak var focusAreaImage: UIImageView!
    @IBOutlet weak var captureEffectView: UIView!
    
    // Constraints
    @IBOutlet weak var cameraViewConstraintAspectNomal: NSLayoutConstraint!
    @IBOutlet weak var cameraViewConstraintAspectSquare: NSLayoutConstraint!
    @IBOutlet weak var cameraViewConstraintAspectWide: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonStackViewConstraintTop: NSLayoutConstraint!
    
    var cameraViewConstraintCenterDefualt: NSLayoutConstraint!
    var cameraViewConstraintCenterWide: NSLayoutConstraint!

    // tmp value
    var flag: Int = 0
}

//MARK: - @IBAction & @objc
extension ViewController {
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
        catch {
            print(error)
        }
    }
    @IBAction func toggleFlash(_ sender: UIButton) {
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
    @IBAction func toggleTimer(_ sender: UIButton) {
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
    
    @IBAction func changeSize(_ sender: UIButton) {
        //TODO: 레이아웃 변경을 위한 임시 코드임
        switch flag {
        case 0: // Nomal to Square
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectNomal)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectSquare)
            
            flag = 1
        case 1: // Square to Wide
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectSquare)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectWide)
            
            self.view.addConstraint(self.cameraViewConstraintCenterWide)
        
            flag = 2
        case 2: //Wide to Nomal
            self.cameraView.removeConstraint(self.cameraViewConstraintAspectWide)
            self.cameraView.addConstraint(self.cameraViewConstraintAspectNomal)
            
            self.view.removeConstraint(self.cameraViewConstraintCenterWide)
    
            flag = 0
        default:
            return
        }
        
        UIView.animate(withDuration: 0.185, delay: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        try? self.cameraController.displayPreview(on: self.cameraPreviewView)
        try? self.cameraController.resetPointOfInterest()
    }
    
    @objc func capturePreviewViewTaped(sender : UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapedPoint = sender.location(in: self.cameraPreviewView)
            try? cameraController.setPointOfInterest(point: tapedPoint)
        }
    }
    
    @IBAction func album(_ sender: UIButton) {
        //TODO: 이 코드는 간단하게 앨범을 보여주는 코드임 -> 추후 라이브러리를 사용하던 새로 만들던 해서 깔끔하게 만들 필요가 있음
        uiImagePicker.allowsEditing = false
        uiImagePicker.sourceType = .savedPhotosAlbum
        uiImagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        present(uiImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
        
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } 
    }
    
    @objc func prepareCameraController() {
        cameraController.timerCountLable = self.timerCountLable
        cameraController.focusAreaDefaultImage = self.focusAreaDefaultImage
        cameraController.focusAreaImage = self.focusAreaImage
        cameraController.captureEffectView = self.captureEffectView
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.cameraPreviewView)
            try? self.cameraController.resetPointOfInterest()
        }
    }
    
    @objc func stopCameraController() {
        try? cameraController.stop()
    }
}

//MARK: - Override member
extension ViewController {
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
                
                // for overlay bottom button on camera preview
                self.view.removeConstraint(self.bottomButtonStackViewConstraintTop)
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
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.capturePreviewViewTaped))
        self.cameraPreviewView.addGestureRecognizer(gesture)
        
        self.innerCaptureImage.image = innerCaptureImage.image?.withRenderingMode(.alwaysTemplate)
        self.innerCaptureImage.tintColor = UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.9, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareCameraController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopCameraController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

