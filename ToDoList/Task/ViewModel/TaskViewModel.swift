//
//  NewTaskViewModel.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 17.11.2024.
//

import Foundation

protocol TaskViewModelProtocol {
    var task: UserTask? { get set }
    
    func delete()
    func save(with toDo: String, and toDoDescription: String, date: Date)
}

final class TaskViewModel: TaskViewModelProtocol {
    // MARK: - Properties
    var task: UserTask?
    
    // MARK: - Life Cycle
    init(task: UserTask?) {
        self.task = task
    }
    
    // MARK: - Methods
    func save(with toDo: String, and toDoDescription: String, date: Date) {
        let date = Date()
        
        let allTasks = TaskPersistant.fetchAll()
        let countOfTasks = allTasks.count
        let uniqueId = countOfTasks + 2
        
        let task = UserTask(toDoDescription: toDoDescription, id: Int(uniqueId), toDo: toDo, isCompleted: false, userId: Int(uniqueId), date: date)
        TaskPersistant.save(task)
    }
    
    func delete() {
        guard let task = task else { return }
        TaskPersistant.delete(task)
    }
}
