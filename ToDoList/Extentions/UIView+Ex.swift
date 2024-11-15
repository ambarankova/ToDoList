//
//  UIView+Ex.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 14.11.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { view in
            addSubview(view)
        }
    }
}
