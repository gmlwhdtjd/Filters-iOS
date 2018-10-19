//
//  FilterController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 7..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import Foundation
import CoreImage
import SQLite

class FilterController {
    static let shared = FilterController()
    static let componentsList = [
        "CIColorControls",
        "CIExposureAdjust",
        "CIHighlightShadowAdjust",
        "ColorOverlay",
        "CIUnsharpMask",
        "Grain",
        "CIVignette",
        "ChromaticAberration",
        "SelectiveBlur",
    ]
    
    var customFilterRecipeList: [FilterRecipe] = []
    
    private var currentFilterRecipe = FilterRecipe()
    var currentFilterChain = CIFIlterChain()
    
    private init() {
        CustomFiltersConstructor.registerFilters()
        try? updateFilterRecipeLists()
    }
}

// MARK: - DataBase controller
extension FilterController {
    func updateFilterRecipeLists() throws {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let db = try Connection("\(path)/CustomFilters.sqlite3")
        
        let filterRecipes = Table("filterRecipes")
        
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        let json = Expression<SQLite.Blob>("json")
        
        try db.run(filterRecipes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(json)
        })
        
        customFilterRecipeList.removeAll()

        for recipe in try db.prepare(filterRecipes) {
            customFilterRecipeList.append(FilterRecipe(type: .custom, id: recipe[id], name: recipe[name]))
        }
    }
    
    func saveCurrentFilterRecipe() {
        currentFilterRecipe.save(jsonData: currentFilterChain.json) {
            do {
                try self.updateFilterRecipeLists()
                
                guard let rowId = $0 else {
                    return
                }
                
                self.currentFilterRecipe = self.customFilterRecipeList.filter { $0.rowId == rowId }[0]
                self.currentFilterChain = try CIFIlterChain(withJson: self.currentFilterRecipe.json)
            }
            catch {
                NSLog(error.localizedDescription)
                self.currentFilterRecipe = FilterRecipe()
                self.currentFilterChain = CIFIlterChain()
            }
        }
    }
    
    func removeCurrentFilterRecipe() {
        currentFilterRecipe.remove() { _ in
            do {
                try self.updateFilterRecipeLists()
            }
            catch {
                NSLog(error.localizedDescription)
            }
            self.currentFilterRecipe = FilterRecipe()
            self.currentFilterChain = CIFIlterChain()
        }
    }
    
    func setCurrentFilterRecipe(type: FilterRecipe.filterType, index: Int) {
        switch type {
        case .original:
            currentFilterRecipe = FilterRecipe()
            currentFilterChain = CIFIlterChain()
        case .reference:
            break; // TODO : Reference filters
        case .custom:
            do {
                currentFilterRecipe = customFilterRecipeList[index]
                currentFilterChain = try CIFIlterChain(withJson: currentFilterRecipe.json)
            }
            catch {
                NSLog(error.localizedDescription)
                currentFilterRecipe = FilterRecipe()
                currentFilterChain = CIFIlterChain()
            }
        }
    }
    
    func getCurrentFilterRecipeIndex() -> (FilterRecipe.filterType, Int) {
        return (.custom, 0)
    }
}

extension FilterController {
    public enum FilterControllerError: Swift.Error {
        case unknown
    }
}
