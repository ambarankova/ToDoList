//
//  NetworkingError.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 15.11.2024.
//

import Foundation

enum NetworkingError: Error {
    case networkingError(_ code: Error)
    case unknown
}
