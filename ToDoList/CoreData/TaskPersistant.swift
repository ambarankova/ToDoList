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
    
    static func save(_ task: TaskObject) {
        var entity: TaskListEntity?
        
        //        if let ent = getEntity(for: task) {
        //            entity = ent
        //        } else {
        //            guard let description = NSEntityDescription.entity(forEntityName: "TaskListEntity", in: context) else { return }
        //            entity = TaskListEntity(entity: description,
        //                                    insertInto: context)
        //        }
        //
        //        entity?.id = Int64(task.id)
        //        entity?.toDo = task.toDo
        //        entity?.isCompleted = task.isCompleted
        //        entity?.userId = Int64(task.userId)
        //
        //        saveContext()
        //    }
        
        if let entity = getEntity(for: task) {
            // Если сущность существует, обновляем её
            entity.id = Int64(task.id)
            entity.toDo = task.toDo
            entity.isCompleted = task.isCompleted
            entity.userId = Int64(task.userId)
        } else {
            // Если сущности с таким id нет, создаем новую
            guard let description = NSEntityDescription.entity(forEntityName: "TaskListEntity", in: context) else { return }
            let newEntity = TaskListEntity(entity: description, insertInto: context)
            newEntity.id = Int64(task.id)
            newEntity.toDo = task.toDo
            newEntity.isCompleted = task.isCompleted
            newEntity.userId = Int64(task.userId)
        }
        
        saveContext()
    }
    
    
    static func delete(_ task: TaskObject) {
        guard let entity = getEntity(for: task) else { return }
        context.delete(entity)
        saveContext()
    }
    
    static func fetchAll() -> [TaskObject] {
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
    private static func convert(entities: [TaskListEntity]) -> [TaskObject] {
        let tasks = entities.map {
            TaskObject(id: Int($0.id),
                       toDo: $0.toDo ?? "",
                       isCompleted: $0.isCompleted,
                       userId: Int($0.userId))
        }
        return tasks
    }
    
//    private static func postNotification() {
//        NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
//    }
    
    private static func getEntity(for task: TaskObject) -> TaskListEntity? {
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
//            postNotification()
        } catch let error {
            debugPrint("Save note error: \(error)")
        }
    }
}

