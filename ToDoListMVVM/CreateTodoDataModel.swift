//
//  TodoDataModel.swift
//  todoList
//
//  Created by Nutan Niraula on 5/25/18.
//  Copyright © 2018 SmartMobe. All rights reserved.
//

import Foundation

struct ToDoListModel: Codable {
    var taskTitle: String
    var taskDescription: String
    var taskAddedDate: String
    var expiryDate: String
    
    private enum CodingKeys: String, CodingKey {
        case taskTitle = "task_title"
        case taskDescription = "task_description"
        case taskAddedDate = "task_added_date"
        case expiryDate = "expiry_date"
    }
}
