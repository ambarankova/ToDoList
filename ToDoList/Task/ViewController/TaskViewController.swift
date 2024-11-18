//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 17.11.2024.
//

import UIKit

final class TaskViewController: UIViewController, UITextViewDelegate {
    // MARK: - GUI Variables
    private lazy var titleTextView: UITextView = {
        let title = UITextView()
        title.textColor = .softWhite
        title.font = .boldSystemFont(ofSize: 34)
        title.backgroundColor = .softBlack
        title.isScrollEnabled = false
        title.textContainer.maximumNumberOfLines = 3
        title.textContainer.lineBreakMode = .byWordWrapping
        return title
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let description = UITextView()
        description.font = .systemFont(ofSize: 16)
        description.textColor = .softWhite
        description.backgroundColor = .softBlack
        return description
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .stroke
        return label
    }()
    
    // MARK: - Properties
    var viewModel: TaskViewModelProtocol?
    let dateFormatter = DateFormatter()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.delegate = self
        configure()
        setupUI()
    }
    
    // MARK: - Public Methods
//    func set(task: UserTask) {
//        titleTextView.text = task.toDo
//        descriptionTextView.text = task.toDoDescription
//        
//        dateFormatter.dateFormat = "dd/MM/yy"
//        dateLabel.text = dateFormatter.string(from: task.date ?? Date())
//    }
}

// MARK: - Private Methods
private extension TaskViewController {
    func configure() {
        if let task = viewModel?.task {
            titleTextView.text = task.toDo
            descriptionTextView.text = task.toDoDescription
            
            dateFormatter.dateFormat = "dd/MM/yy"
            dateLabel.text = dateFormatter.string(from: task.date ?? Date())
        } else {
            titleTextView.text = "To Do"
            descriptionTextView.text = "To do"
            
            dateFormatter.dateFormat = "dd/MM/yy"
            dateLabel.text = dateFormatter.string(from: Date())
        }
    }
    
    func setupUI() {
        view.addSubviews([titleTextView, dateLabel, descriptionTextView])
        view.backgroundColor = .softBlack
        navigationController?.navigationBar.tintColor = .brightYellow
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(recognizer)
        
        setupConstraints()
        setupBars()
    }
    
    func setupConstraints() {
        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.lessThanOrEqualTo(150)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(20)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupBars() {
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                          target: self,
                                          action: #selector(deleteAction))
        trashButton.tintColor = .brightYellow
        let saveButton = UIBarButtonItem(title: "Save",
                                             image: nil,
                                             target: self,
                                         action: #selector(saveAction))
        let spacing = UIBarButtonItem(systemItem: .flexibleSpace)
        
        guard let vm = viewModel else { return }
        if vm.task == nil {
            setToolbarItems([saveButton], animated: true)
        } else {
            setToolbarItems([trashButton, spacing, saveButton], animated: true)
        }
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = .stroke
        navigationController?.toolbar.tintColor = .softWhite
    }
    
    @objc func hideKeyboard() {
        descriptionTextView.resignFirstResponder()
    }
    
    @objc func saveAction() {
        viewModel?.save(with: titleTextView.text ?? "", and: descriptionTextView.text, date: Date())
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteAction() {
        viewModel?.delete()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func goToBack() {
        navigationController?.popViewController(animated: true)
    }
}
