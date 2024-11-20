//
//  TasksListTableTests.swift
//  ToDoListTests
//
//  Created by Анастасия Ахановская on 20.11.2024.
//

import XCTest
@testable import ToDoList

final class TasksListViewControllerTests: XCTestCase {
    
    func testTableViewUpdatesAfterLoadingData() {
        // Arrange
        let viewController = TasksListViewController()
        viewController.loadViewIfNeeded()
        let mockViewModel = MockTasksListViewModel()
        viewController.viewModel = mockViewModel
        
        let task = UserTask(toDoDescription: "Test Task", id: 1, toDo: "Task 1", isCompleted: false, userId: 1, date: Date())
        mockViewModel.mockTasks = [task]
        
        // Act
        viewController.viewModel?.loadData(searchText: nil)
        viewController.table.reloadData()
        
        // Assert
        XCTAssertEqual(viewController.table.numberOfRows(inSection: 0), 1)
    }
}

final class MockTasksListViewModel: TasksListViewModelProtocol {
    var reloadData: (() -> Void)?
    var filteredTasks: [ToDoList.UserTask] = []
    
    func loadData() {}
    func getTasks() {}
    func fetchTasks() -> [ToDoList.UserTask] {
        return []
    }
    func done(_ task: ToDoList.UserTask) {}
    
    var mockTasks: [UserTask] = []
    var sections: [TableViewSection] = []
    
    func loadData(searchText: String?) {
        sections = [TableViewSection(items: mockTasks)]
    }
    
    func setupSection() {}
    func delete(_ task: UserTask) {}
}
