//
//  TaskPersistant.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 17.11.2024.
//

import Foundation
import CoreData

final class TaskPersistant {
    // MARK: - Properties
    private static let context = AppDelegate.persistentContainer.viewContext
    
    // MARK: - Public Methods
    static func save(_ task: UserTask) {
        let entity: TaskListEntity
        if let existingEntity = getEntity(for: task) {
            entity = existingEntity
        } else {
            guard let description = NSEntityDescription.entity(forEntityName: "TaskListEntity", in: context) else {
                return
            }
            entity = TaskListEntity(entity: description, insertInto: context)
        }
        
        entity.id = Int64(task.id)
        entity.toDo = task.toDo
        entity.isCompleted = task.isCompleted
        entity.userId = Int64(task.userId)
        entity.toDoDescription = task.toDoDescription ?? task.toDo
        entity.date = task.date ?? Date()
        
        saveContext()
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    }
    
    static func delete(_ task: UserTask) {
        guard let entity = getEntity(for: task) else { return }
        context.delete(entity)
        saveContext()
        NotificationCenter.default.post(name: .tasksUpdated, object: nil)
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
        let predicate = NSPredicate(format: "id == %d", Int64(task.id))
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
            print("Save context error: \(error)")
        }
    }
}

