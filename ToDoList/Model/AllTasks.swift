//
//  AllTasks.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 15.11.2024.
//

import Foundation

struct AllTasksObjects: Decodable {
    let todos: [TaskObject]
    let total: Int
    let skip: Int
    let limit: Int
    
    enum CodingKeys: CodingKey {
        case todos
        case total
        case skip
        case limit
    }
}
