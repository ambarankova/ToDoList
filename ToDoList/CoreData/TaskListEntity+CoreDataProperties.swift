//
//  TaskListEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 17.11.2024.
//
//

import Foundation
import CoreData


extension TaskListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskListEntity> {
        return NSFetchRequest<TaskListEntity>(entityName: "TaskListEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var isCompleted: Bool
    @NSManaged public var toDo: String
    @NSManaged public var toDoDescription: String?
    @NSManaged public var userId: Int64

}

extension TaskListEntity : Identifiable {

}
