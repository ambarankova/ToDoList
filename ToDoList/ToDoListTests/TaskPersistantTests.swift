//
//  TaskPersistantTests.swift
//  ToDoListTests
//
//  Created by Анастасия Ахановская on 20.11.2024.
//

import XCTest
@testable import ToDoList

final class TaskPersistentTests: XCTestCase {
    
    func testSaveTask() {
        // Arrange
        let task = UserTask(toDoDescription: "Test Task", id: 1, toDo: "Do something", isCompleted: false, userId: 1, date: Date())
        
        // Act
        TaskPersistant.save(task)
        let allTasks = TaskPersistant.fetchAll()
        
        // Assert
        XCTAssertTrue(allTasks.contains(where: { $0.id == task.id }))
    }
    
    func testDeleteTask() {
        // Arrange
        let task = UserTask(toDoDescription: "Task to delete", id: 2, toDo: "Delete me", isCompleted: false, userId: 1, date: Date())
        TaskPersistant.save(task)
        
        // Act
        TaskPersistant.delete(task)
        let allTasks = TaskPersistant.fetchAll()
        
        // Assert
        XCTAssertFalse(allTasks.contains(where: { $0.id == task.id }))
    }
}
