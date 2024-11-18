//
//  TaskObject.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 15.11.2024.
//

import Foundation

struct TaskObject: Decodable, TableViewItemsProtocol {
    let id: Int
    var toDo: String
    var isCompleted: Bool
    let userId: Int
    
    var date: Date?
    var toDoDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case toDo = "todo"
        case isCompleted = "completed"
        case userId
    }
}
