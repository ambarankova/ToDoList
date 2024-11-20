//
//  ApiManager.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 15.11.2024.
//

import Foundation

final class ApiManager {
    // MARK: - Properties
    private static let baseUrl = "https://dummyjson.com/todos"
    
    // MARK: - Public Methods
    static func getTasks(completion: @escaping (Result<[TaskObject], Error>) -> ()) {
        guard let url = URL(string: baseUrl) else { return }
        
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            handleRespond(data: data, error: error, completion: completion)
        }
        session.resume()
    }
    
    // MARK: - Private Methods
    private static func handleRespond(data: Data?, error: Error?, completion: @escaping (Result<[TaskObject], Error>) -> ()) {
        
        if let error = error {
            completion(.failure(NetworkingError.networkingError(error)))
        } else if let data = data {
            do {
                let model = try JSONDecoder().decode(AllTasksObjects.self,
                                                     from: data)
                completion(.success(model.todos))
            }
            catch let decodeError {
                completion(.failure(decodeError))
            }
        } else {
            completion(.failure(NetworkingError.unknown))
        }
    }
}

