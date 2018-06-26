//
//  ViewController.swift
//  todoList
//
//  Created by Nutan Niraula on 5/25/18.
//  Copyright © 2018 SmartMobe. All rights reserved.
//
import RxSwift
import RxCocoa
import UIKit

class CreateTodoViewController: UIViewController {
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    @IBOutlet weak var taskExpiryDateTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var networkCallStatusLabel: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    var alert: UIAlertController!
    var dateToolBar: UIToolbar!
    var datePicker = UIDatePicker()
    var viewModel = CreateTodoViewModel()
    var disposeBag = DisposeBag()
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        viewModel.savePostToNetwork()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVisualStyleToView()
        bindUiVariablesToViewModel()
    }
    
    // View layout code
    private func addVisualStyleToView() {
        addCornerRadiusToContainerView()
        addCornerRadiusToSaveButton()
        addDatePickerInInputAccessoryView()
    }
    
    private func addCornerRadiusToContainerView() {
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
    }
    
    private func addCornerRadiusToSaveButton() {
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
    }
    
    //Activity Indicator Code
    private func showActivityIndicator() {
        alert = UIAlertController(title: nil, message: "Saving...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func hideActivityIndicator() {
        alert.dismiss(animated: true, completion: nil)
    }
    
    //add toolbar
    private func addDatePickerInInputAccessoryView() {
        dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(onDoneTapped))
        doneBtn.tintColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        dateToolBar.setItems([flexibleSpace,doneBtn], animated: true)
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        taskExpiryDateTextField.inputAccessoryView = dateToolBar
        taskExpiryDateTextField.inputView = datePicker
    }
    
    @objc private func onDoneTapped() {
        taskExpiryDateTextField.text = viewModel.createDateString(fromDate: datePicker.date)
        self.view.endEditing(true)
    }
    
    //data binding code
    private func bindUiVariablesToViewModel() {
        taskTitleTextField.rx.text.orEmpty.asObservable().bind(to: viewModel.titleText).disposed(by: disposeBag)
        taskDescriptionTextField.rx.text.orEmpty.asObservable().bind(to: viewModel.descriptionText).disposed(by: disposeBag)
        taskExpiryDateTextField.rx.text.orEmpty.asObservable().bind(to: viewModel.expiryDate).disposed(by: disposeBag)
        viewModel.networkCallStatusText.asObservable().do(onNext: { [weak self](statusString) in
            if statusString == "Task Created" {
                self?.setLabelTextColor(color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1))
            } else {
                self?.setLabelTextColor(color: .red)
            }
        }).bind(to: networkCallStatusLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.activityIndicatorObservable.asObservable().subscribe(onNext: { [weak self](shouldShow) in
            if shouldShow {
                self?.showActivityIndicator()
            } else {
                self?.hideActivityIndicator()
                self?.clearData()
            }
            }, onError: { [weak self] error in
                self?.hideActivityIndicator()
        }).disposed(by: disposeBag)
    }
    
    private func clearData() {
        DispatchQueue.main.async {
            self.taskTitleTextField.text = ""
            self.taskDescriptionTextField.text = ""
            self.taskExpiryDateTextField.text = ""
        }
    }
    
    private func setLabelTextColor(color: UIColor) {
        DispatchQueue.main.async {
            self.networkCallStatusLabel.textColor = color
        }
    }
}

