//
//  TaskPersistant.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 17.11.2024.
//

import Foundation
import CoreData

final class TaskPersistant {
    private static let context = AppDelegate.persistentContainer.viewContext
    
    static func save(_ task: UserTask) {
        if let entity = getEntity(for: task) {
            entity.id = Int64(task.id)
            entity.toDo = task.toDo
            entity.isCompleted = task.isCompleted
            entity.userId = Int64(task.userId)
            entity.toDoDescription = task.toDoDescription ?? task.toDo
            entity.date = task.date ?? Date()
        } else {
            guard let description = NSEntityDescription.entity(forEntityName: "TaskListEntity", in: context) else { return }
            let newEntity = TaskListEntity(entity: description, insertInto: context)
            newEntity.id = Int64(task.id)
            newEntity.toDo = task.toDo
            newEntity.isCompleted = task.isCompleted
            newEntity.userId = Int64(task.userId)
            newEntity.toDoDescription = task.toDoDescription ?? task.toDo
            newEntity.date = task.date ?? Date()
        }
        
        print("Task details:")
        print("id: \(task.id), toDo: \(task.toDo), isCompleted: \(task.isCompleted), userId: \(task.userId), description: \(task.toDoDescription ?? task.toDo), date: \(task.date ?? Date())")
        
        saveContext()
    }
    
    static func delete(_ task: UserTask) {
        guard let entity = getEntity(for: task) else { return }
        context.delete(entity)
        saveContext()
    }
    
    static func fetchAll() -> [UserTask] {
        let request = TaskListEntity.fetchRequest()
        
        do {
            let objects = try context.fetch(request)
            return convert(entities: objects)
        } catch let error {
            debugPrint("Fetch notes error: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    private static func convert(entities: [TaskListEntity]) -> [UserTask] {
        let tasks = entities.map {
            UserTask(toDoDescription: $0.toDoDescription ?? $0.toDo,
                     id: Int($0.id),
                     toDo: $0.toDo,
                     isCompleted: $0.isCompleted,
                     userId: Int($0.userId),
                     date: $0.date ?? Date())
        }
        return tasks
    }
    
    private static func getEntity(for task: UserTask) -> TaskListEntity? {
        let request = TaskListEntity.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", task.id)
        request.predicate = predicate
        
        do {
            let objects = try context.fetch(request)
            return objects.first
        } catch let error {
            debugPrint("Fetch notes error: \(error)")
            return nil
        }
    }
    
    private static func saveContext() {
        do {
            try context.save()
        } catch let error {
            debugPrint("Save note error: \(error)")
        }
    }
}

