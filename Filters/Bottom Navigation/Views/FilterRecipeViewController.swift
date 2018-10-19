//
//  FilterRecipeViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 13..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class FilterRecipeViewController: UIViewController{
    let filterController = FilterController.shared
    
    var selectedComponentIndex: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
}

extension FilterRecipeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toModifyView":
            if let modifyViewController = segue.destination as? ModifyViewController {
                modifyViewController.componentIndex = self.selectedComponentIndex
            }
        default:
            break
        }
    }
    
    @objc func backToHome(sender : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                    return
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        filterController.saveCurrentFilterRecipe()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addMore(_ sender: Any) {
        performSegue(withIdentifier: "toAddComponentView", sender: self)
    }
    
    @IBAction func unwindToFilterRecipeView(sender: UIStoryboardSegue) {
        collectionView.reloadData()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension FilterRecipeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterController.currentFilterChain.components.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterRecipeComponentCell", for: indexPath) as! FilterRecipeComponentCell
        
        cell.filterName = filterController.currentFilterChain.components[indexPath.row].name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedComponentIndex = indexPath.row
        performSegue(withIdentifier: "toModifyView", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.item < destinationIndexPath.item {
            for index in sourceIndexPath.item ..< destinationIndexPath.item {
                filterController.currentFilterChain.components.swapAt(index, index + 1)
            }
        }
        else if sourceIndexPath.item > destinationIndexPath.item {
            for index in (destinationIndexPath.item ..< sourceIndexPath.item).reversed() {
                filterController.currentFilterChain.components.swapAt(index, index + 1)
            }
        }
    }
}

class FilterRecipeComponentCell: UICollectionViewCell {
    
    var filterName: String? {
        didSet {
            switch filterName {
            case "CIExposureAdjust":
                componentLabel.text = "Exposure"
            case "CIHighlightShadowAdjust":
                componentLabel.text = "Tone"
            case "CIColorControls":
                componentLabel.text = "Basic"
            case "CIUnsharpMask":
                componentLabel.text = "Sharpen"
            case "CIVignette":
                componentLabel.text = "Vignette"
            case "ColorOverlay":
                componentLabel.text = "Color"
            case "Grain":
                componentLabel.text = "Grain"
            case "ChromaticAberration":
                componentLabel.text = "Color Distortion"
            case "SelectiveBlur":
                componentLabel.text = "Blur"
            default:
                componentLabel.text = nil
            }
        }
    }
    
    @IBOutlet private weak var componentLabel: UILabel!
    
    override func prepareForReuse() {
        self.componentLabel.text = ""
        //        self.componentButton.imageView?.image = nil
    }
}
