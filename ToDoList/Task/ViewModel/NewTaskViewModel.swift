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

final class NewTaskViewModel: TaskViewModelProtocol {
    // MARK: - Properties
    var task: UserTask?
    
    // MARK: - Life Cycle
    init(task: UserTask?) {
        self.task = task
    }
    
    // MARK: - Methods
    func save(with toDo: String, and toDoDescription: String, date: Date) {
        let date = Date()
        
        let task = UserTask(toDoDescription: toDoDescription, id: 1, toDo: toDo, isCompleted: false, userId: 1, date: date)
        TaskPersistant.save(task)
    }
    
    func delete() {
        guard let task = task else { return }
        TaskPersistant.delete(task)
    }
}
