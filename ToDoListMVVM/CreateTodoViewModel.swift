//
//  CreateTodoViewModel.swift
//  todoList
//
//  Created by Nutan Niraula on 5/25/18.
//  Copyright © 2018 SmartMobe. All rights reserved.
//

import Foundation
import RxSwift

class CreateTodoViewModel {
    var titleText = Variable<String>("")
    var descriptionText = Variable<String>("")
    var addedDate = Variable<String>("")
    var expiryDate = Variable<String>("")
    var networkCallStatusText = Variable<String>("Waiting for network call")
    var activityIndicatorObservable = PublishSubject<Bool>()
    
    //provide dependency injection
    init() {
        
    }
    
    func savePostToNetwork() {
        //Network call to save model
        guard titleText.value != "" && descriptionText.value != "" && expiryDate.value != ""
            else {
                networkCallStatusText.value = "Please fill all the required fields"
                return
        }
        // initializing url for post request
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        // constructing url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        activityIndicatorObservable.onNext(true)
        // creating json encoded model to send in body of the post
        let dataToSave = ToDoListModel(taskTitle: titleText.value, taskDescription: descriptionText.value, taskAddedDate: createDateString(fromDate: Date()), expiryDate: expiryDate.value)
        do {
            let jsonBody = try JSONEncoder().encode(dataToSave)
            request.httpBody = jsonBody
        } catch {}
        
        //making api request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self](data, _, _) in
            guard let data = data else { return }
            do {
                //decoding api response
                let sentPost = try JSONDecoder().decode(ToDoListModel.self, from: data)
                print(sentPost)
                self?.networkCallStatusText.value = "Task Created"
                self?.activityIndicatorObservable.onNext(false)
            } catch let error {
                self?.networkCallStatusText.value = "Failed to save task"
                self?.activityIndicatorObservable.onError(error)
            }
        }
        task.resume()
    }
    
    func createDateString(fromDate date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        let date = dateFormatter.date(from:dateString)!
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from:date)
    }
}
