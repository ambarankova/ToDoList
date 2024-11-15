//
//  String+Ex.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 14.11.2024.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
