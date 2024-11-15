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
}

final class TasksListViewModel: TasksListViewModelProtocol {
    // MARK: - Properties
    var reloadData: (() -> Void)?
    var showError: ((String) -> Void)?
    var sections: [TableViewSection] = [] {
        didSet {
            DispatchQueue.main.async {
                self.reloadData?()
            }
        }
    }
    
    // MARK: - Public Methods
    func loadData() {
        ApiManager.getTasks() { [weak self] result in
            self?.handleResult(result)
        }
    }
}

// MARK: - Private
private extension TasksListViewModel {
    func handleResult(_ result: Result<[TaskObject], Error>) {
        switch result {
        case .success(let tasks):
            self.convertToCell(tasks)
//            self.saveToPersistant(tasks)
        case .failure(let error):
            DispatchQueue.main.async {
                self.showError?(error.localizedDescription)
            }
        }
    }
    
    func convertToCell(_ tasks: [TaskObject]) {
        if sections.isEmpty {
            let firstSection = TableViewSection(items: tasks)
            sections = [firstSection]
            print(sections)
        } else {
            sections[0].items += tasks
        }
    }
}
