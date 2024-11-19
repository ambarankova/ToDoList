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
    func getTasks()
    func fetchTasks() -> [UserTask]
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
    
    // MARK: - Life Cycle
    init() {
        getTasks()
    }
    
    // MARK: - Public Methods
    func loadData() {
        ApiManager.getTasks() { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    func setupSection() {
        let allTasks = fetchTasks()
        sections = [TableViewSection(items: allTasks)]
    }
    
    func fetchTasks() -> [UserTask] {
        return TaskPersistant.fetchAll()
    }
    
    func getTasks() {
        let tasks = TaskPersistant.fetchAll()
        sections = []
        
        let groupedObjects = tasks.reduce(into: [Date: [UserTask]]()) { result, task in
            let date = Calendar.current.startOfDay(for: task.date ?? Date())
            result[date, default: []].append(task)
        }
        
        let keys = groupedObjects.keys
        keys.forEach { key in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            sections.append(TableViewSection(items: groupedObjects[key] ?? []))
        }
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
