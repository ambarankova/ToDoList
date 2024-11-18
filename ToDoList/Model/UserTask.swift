//
//  UserTask.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 18.11.2024.
//

import Foundation

struct UserTask: TableViewItemsProtocol {
    var toDoDescription: String?
    var id: Int
    var toDo: String
    var isCompleted: Bool
    var userId: Int
    var date: Date?
}
