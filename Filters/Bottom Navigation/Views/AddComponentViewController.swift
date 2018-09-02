//
//  AddComponentViewController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 27..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class AddComponentViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let filterController = FilterController.shared
    private var selectedComponentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toModifyView":
            if let modifyViewController = segue.destination as? ModifyViewController {
                modifyViewController.componentIndex = selectedComponentIndex
            }
        default:
            break
        }
    }
    
    @objc func backToHome(sender : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension AddComponentViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FilterController.componentsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterRecipeComponentCell", for: indexPath) as! FilterRecipeComponentCell
        
        cell.filterName = FilterController.componentsList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterController.currentFilterChain.components.append(CIFilter(name: FilterController.componentsList[indexPath.row])!)
        selectedComponentIndex = filterController.currentFilterChain.components.endIndex - 1
        performSegue(withIdentifier: "toModifyView", sender: self)
    }
}
