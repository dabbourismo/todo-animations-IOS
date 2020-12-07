//
//  Note.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/8/20.
//

import Foundation

struct Note : Codable{
    var title:String
    var completed:Bool
    var createdAt:Date
    var id:UUID
    
    public func saveItem() {
        DataManager.save(self, with: id.uuidString)
    }
    
    func deleteItem() {
        DataManager.delete(id.uuidString)
    }
    
     mutating func markAsCompleted() {
        self.completed = true
        DataManager.save(self, with: id.uuidString)
    }
}
