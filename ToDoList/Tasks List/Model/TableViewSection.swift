//
//  TableViewSection.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 15.11.2024.
//

import Foundation

protocol TableViewItemsProtocol {
    var id: Int { get }
    var toDo: String { get set }
    var toDoDescription: String? { get set }
    var isCompleted: Bool { get set }
    var userId: Int { get }
    var date: Date? { get }
}

struct TableViewSection {
    var items: [TableViewItemsProtocol]
}
