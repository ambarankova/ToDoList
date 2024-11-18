//
//  TasksListViewModel.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 14.11.2024.
//

import Foundation

protocol TasksListViewModelProtocol {
    var sections: [TableViewSection] { get set }
    var reloadData: (() -> Void)? { get set }
    
    func loadData()
    func setupSection()
    func getTasks() -> [UserTask]
    func delete(_ task: UserTask)
}

final class TasksListViewModel: TasksListViewModelProtocol {
    // MARK: - Properties
    var reloadData: (() -> Void)?
    var showError: ((String) -> Void)?
    var sections: [TableViewSection] = [] {
        didSet {
            self.reloadData?()
        }
    }
    
    // MARK: - Public Methods
    func loadData() {
        ApiManager.getTasks() { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    func setupSection() {
        let allTasks = getTasks()
        sections = [TableViewSection(items: allTasks)]
    }
    
    func getTasks() -> [UserTask] {
        return TaskPersistant.fetchAll()
    }
    
    func delete(_ task: UserTask) {
        TaskPersistant.delete(task)
    }
}

// MARK: - Private Methods
private extension TasksListViewModel {
    func handleResult(_ result: Result<[TaskObject], Error>) {
        switch result {
        case .success(let tasks):
            saveToPersistant(tasks)
        case .failure(let error):
            self.showError?(error.localizedDescription)
        }
    }
    
    func saveToPersistant(_ tasks: [TaskObject]) {
        for task in tasks {
            let userTask = UserTask(toDoDescription: task.toDoDescription,
                                    id: task.id,
                                    toDo: task.toDo,
                                    isCompleted: task.isCompleted,
                                    userId: task.userId)
            TaskPersistant.save(userTask)
        }
    }
}
