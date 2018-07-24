//
//  ViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 6. 20..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit
import Photos

//
// This extension has been referenced and modified from stackoverflow.
//
// Original Source
// https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
//
// Modified by Hui Jong Lee
//
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

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
}

//MARK: - Override member
extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func configureCameraController() {
            cameraController.timerCountLable = self.timerCountLable
            cameraController.focusAreaDefaultImage = self.focusAreaDefaultImage
            cameraController.focusAreaImage = self.focusAreaImage
            cameraController.captureEffectView = self.captureEffectView
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.cameraPreviewView)
            }
        }
        
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
        
        configureCameraViewConstraint()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.capturePreviewViewTaped))
        self.cameraPreviewView.addGestureRecognizer(gesture)
        
        configureCameraController()
        
        innerCaptureImage.image = innerCaptureImage.image?.withRenderingMode(.alwaysTemplate)
        innerCaptureImage.tintColor = UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.9, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

