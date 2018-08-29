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
    private var selectedFilterComponent: CIFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.backToHome))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toModifyView":
            if let modifyViewController = segue.destination as? ModifyViewController {
                modifyViewController.currentComponent = selectedFilterComponent
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
    
        selectedFilterComponent = CIFilter(name: FilterController.componentsList[indexPath.row])
        filterController.currentFilterChain.components.append(selectedFilterComponent!)
        
        performSegue(withIdentifier: "toModifyView", sender: self)
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
        print("\(indexPath.row) with collectionView")
    }
}
