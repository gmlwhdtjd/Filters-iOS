//
//  BottomButtonsViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 25..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit
import Photos

class BottomButtonsViewController: UIViewController {
    var mainViewController: MainViewController!
    let uiImagePicker = UIImagePickerController()
    
    @IBOutlet weak var innerCaptureImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainViewController = parent?.parent as! MainViewController
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.capturePreviewViewTaped))
        self.view.addGestureRecognizer(gesture)
        
        self.innerCaptureImage.image = innerCaptureImage.image?.withRenderingMode(.alwaysTemplate)
        self.innerCaptureImage.tintColor = UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.9, alpha: 1.0)
    }
    
    @objc func capturePreviewViewTaped(sender : UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapedPoint = sender.location(in: mainViewController.cameraPreviewView)
            if mainViewController.cameraPreviewView.bounds.contains(tapedPoint) {
                try? mainViewController.cameraController.setPointOfInterest(point: tapedPoint)
            }
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
        mainViewController.cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    @IBAction func edit(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilterRecipeView", sender: self)
    }
}
