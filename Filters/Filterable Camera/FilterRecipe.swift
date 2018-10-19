//
//  FilterRecipe.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 9. 6..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import Foundation
import SQLite

class FilterRecipe {
    let type: filterType
    let rowId: Int64?
    
    var name: String
    var json: Data? {
        get {
            guard let rowId = self.rowId else {
                return nil
            }
            do {
                let connection: Connection?
                switch type {
                case .original:
                    return nil
                case .reference:
                    return nil // TODO : refernce DB
                case .custom:
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    connection = try Connection("\(path)/CustomFilters.sqlite3")
                }
                
                let filterRecipes = Table("filterRecipes")
                
                let id = Expression<Int64>("id")
                let json = Expression<SQLite.Blob>("json")
                
                guard let db = connection,
                    let filterRecipe = try db.pluck(filterRecipes.filter(id == rowId)) else {
                    return nil
                }
                
                return Data(filterRecipe[json].bytes)
            }
            catch {
                NSLog(error.localizedDescription)
                return nil
            }
        }
    }
    
    convenience init () {
        self.init(type: .original, id: nil, name: "original")
    }
    
    init(type: filterType, id: Int64?, name: String) {
        self.type = .custom
        self.rowId = id
        self.name = name
    }
    
    func save(jsonData: Data, completionHandler: @escaping (Int64?) -> ()) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let db = try Connection("\(path)/CustomFilters.sqlite3")
            
            let filterRecipes = Table("filterRecipes")
            
            let id = Expression<Int64>("id")
            let name = Expression<String>("name")
            let json = Expression<SQLite.Blob>("json")
            
            if self.type == .custom,
                let rowId = self.rowId {
                let alice = filterRecipes.filter(id == rowId)
                let update = alice.update(name <- self.name,
                                          json <- SQLite.Blob(bytes: [UInt8](jsonData)))
                
                if try db.run(update) > 0 {
                    completionHandler(rowId)
                } else {
                    completionHandler(nil)
                }
            }
            else {
                let insert = filterRecipes.insert(name <- self.name,
                                                  json <- SQLite.Blob(bytes: [UInt8](jsonData)))
                completionHandler(try db.run(insert))
            }
        }
        catch {
            NSLog(error.localizedDescription)
            completionHandler(nil)
        }
    }
    
    func remove(completionHandler: @escaping (Bool) -> ()) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let db = try Connection("\(path)/CustomFilters.sqlite3")
            
            let filterRecipes = Table("filterRecipes")
            
            let id = Expression<Int64>("id")
            
            guard self.type == .custom,
                let rowId = self.rowId else {
                completionHandler(false)
                return
            }
            
            let alice = filterRecipes.filter(id == rowId)
            
            if try db.run(alice.delete()) > 0 {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        catch {
            NSLog(error.localizedDescription)
            completionHandler(false)
        }
    }
}

extension FilterRecipe {
    enum filterType {
        case original
        case reference
        case custom
    }
}
