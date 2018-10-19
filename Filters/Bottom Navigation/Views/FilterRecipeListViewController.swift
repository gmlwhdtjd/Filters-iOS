//
//  FilterRecipeListViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 9. 10..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class FilterRecipeListViewController: UIViewController {
    let filterController = FilterController.shared
    
    @IBAction func back(_ sender: Any) {
         navigationController?.popToRootViewController(animated: true)
    }
}

extension FilterRecipeListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return filterController.customFilterRecipeList.count
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterRecipeCell", for: indexPath) as! FilterRecipeCell
        
        if indexPath.section == 0 {
            cell.nameLabel.text = "Original"
        } else {
            cell.nameLabel.text = filterController.customFilterRecipeList[indexPath.row].name
        }
        
        return cell
    }
}

extension FilterRecipeListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            filterController.setCurrentFilterRecipe(type: .original, index: indexPath.row)
        case 1:
            filterController.setCurrentFilterRecipe(type: .custom, index: indexPath.row)
        case 2:
            filterController.setCurrentFilterRecipe(type: .reference, index: indexPath.row)
        default:
            filterController.setCurrentFilterRecipe(type: .original, index: 0)
        }
        
    }
}

extension FilterRecipeListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let left: CGFloat = self.collectionView(collectionView, numberOfItemsInSection: section) == 0 ? 0 : 20
        let right: CGFloat = section != numberOfSections(in: collectionView) - 1 ? 0 : 20
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
}

class FilterRecipeCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func prepareForReuse() {
        self.nameLabel.text = ""
        //        self.componentButton.imageView?.image = nil
    }
}
