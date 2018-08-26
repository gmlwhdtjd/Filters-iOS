//
//  EditerViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 13..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class FilterRecipeViewController: UIViewController{
    let filterController = FilterController.shared
    
    var numberOfComponents = 0
    var selectedComponent: CIFilter?
    
    @IBOutlet weak var collectionView: UICollectionView!
}

extension FilterRecipeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.backToHome))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toModifyView":
            if let modifyViewController = segue.destination as? ModifyViewController {
                modifyViewController.currentComponent = selectedComponent
            }
        default:
            break
        }
    }
    
    @objc func backToHome(sender : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func componentSelected(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: collectionView)
        let indexPath = collectionView!.indexPathForItem(at: point)!
        
        if self.numberOfComponents == indexPath.row{
            // add More
            print("Add More")
        }
        else {
            selectedComponent = filterController.currentFilterChain.components[indexPath.row]
            performSegue(withIdentifier: "toModifyView", sender: self)
        }
    }
}

extension FilterRecipeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.numberOfComponents = filterController.currentFilterChain.components.count
        return self.numberOfComponents + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterRecipeComponentCell", for: indexPath) as! FilterRecipeComponentCell
        
        if indexPath.row == self.numberOfComponents {
            cell.filterName = "AddMore"
        }
        else {
            cell.filterName = filterController.currentFilterChain.components[indexPath.row].name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row) with collectionView")
    }
}
