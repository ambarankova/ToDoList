//
//  TasksListViewController.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 14.11.2024.
//

import SnapKit
import UIKit

final class TasksListViewController: UIViewController {
    // MARK: - GUI Variables
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        setupSearchBar(searchBar)
        return searchBar
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = .softWhite
        title.font = .boldSystemFont(ofSize: 34)
        title.text = "Tasks".localized
        return title
    }()
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.backgroundColor = .softBlack
        return table
    }()
    
    // MARK: - Properties
    var viewModel: TasksListViewModelProtocol?
    var dimmingView: UIView?
    var countOfTasks = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupUI()
        setupViewModel()
        registerObserver()
        
        viewModel?.loadData()
        viewModel?.setupSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBars()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tasksUpdated, object: nil)
    }
}

// MARK: - Private Methods
private extension TasksListViewController {
    func setupViewModel() {
        viewModel?.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
    }
    
    func setupTableView() {
        table.register(TaskTableViewCell.self,
                       forCellReuseIdentifier: TaskTableViewCell.reuseID)
        
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
    }
    
    func setupUI() {
        view.addSubviews([searchBar, table, titleLabel])
        view.backgroundColor = .softBlack
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(recognizer)
        
        searchBar.delegate = self
        
        setupConstraints()
        setupBars()
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().inset(20)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        table.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupSearchBar(_ searchBar: UISearchBar) {
        searchBar.barTintColor = .clear
        searchBar.searchTextField.textColor = .softWhite
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = UIColor.stroke.withAlphaComponent(0.5)
        
        let placeholderText = "Search".localized
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.softWhite.withAlphaComponent(0.5)]
        )
        
        if let iconView = searchBar.searchTextField.leftView as? UIImageView {
            iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = UIColor.softWhite.withAlphaComponent(0.5)
        }
    }
    
    func setupBars() {
        tasksCount()
        
        let countLabel = UIBarButtonItem(title: "\(countOfTasks)" +  "tasks".localized,
                                         image: nil,
                                         target: self,
                                         action: nil)
        
        let newTaskButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil")?.withTintColor(.brightYellow, renderingMode: .alwaysOriginal),
                                            style: .plain,
                                            target: self,
                                            action: #selector(addTask))
        
        let spacing = UIBarButtonItem(systemItem: .flexibleSpace)
        
        setToolbarItems([spacing, countLabel, spacing, newTaskButton], animated: true)
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = .stroke
        navigationController?.toolbar.tintColor = .softWhite
    }
    
    func tasksCount() {
        guard let VM = viewModel else { return }
        let allTasks = VM.fetchTasks()
        countOfTasks = allTasks.count
    }
    
    func editTask(task: UserTask) {
        let editTaskViewController = TaskViewController()
        let viewModel = TaskViewModel(task: task)
        editTaskViewController.viewModel = viewModel
        navigationController?.pushViewController(editTaskViewController, animated: true)
    }
    
    func showDimmedBackground() {
        print("Showing dimmed background...")
        guard dimmingView == nil else { return }
        dimmingView = UIView(frame: view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView?.alpha = 0
        view.addSubview(dimmingView!)
        UIView.animate(withDuration: 0.3) {
            self.dimmingView?.alpha = 1
        }
    }
    
    func removeDimmedBackground() {
        print("Removing dimmed background...")
        guard dimmingView != nil else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmingView?.alpha = 0
        }) { _ in
            self.dimmingView?.removeFromSuperview()
            self.dimmingView = nil
        }
    }
    
    func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTasks), name: .tasksUpdated, object: nil)
    }
    
    @objc private func refreshTasks() {
        DispatchQueue.main.async {
            self.viewModel?.getTasks()
            self.table.reloadData()
        }
    }
    
    @objc func addTask() {
        let newTaskViewController = TaskViewController()
        let viewModel = TaskViewModel(task: nil)
        newTaskViewController.viewModel = viewModel
        navigationController?.pushViewController(newTaskViewController, animated: true)
    }
    
    @objc func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSourse
extension TasksListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.sections[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let task = viewModel?.sections[indexPath.section].items[indexPath.row] as? UserTask,
              let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseID, for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        cell.configure(with: task)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let task = viewModel?.sections[indexPath.section].items[indexPath.row] as? UserTask,
              let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        let editAction = UIAction(title: "Edit".localized, image: UIImage(systemName: "pencil")) { _ in
            self.editTask(task: task)
            self.removeDimmedBackground()
        }
        
        let deleteAction = UIAction(title: "Delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.viewModel?.delete(task)
            self.setupBars()
            self.removeDimmedBackground()
        }
        
        let doneText = task.isCompleted ? "Undone".localized : "Done".localized
        
        let doneAction = UIAction(title: doneText, image: UIImage(systemName: "checkmark")) { _ in
            self.viewModel?.done(task)
            self.removeDimmedBackground()
        }
        
        let shareAction = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up")) { _ in
            print("Sharing...")
        }
        
        let menu = UIMenu(title: "", children: [doneAction, editAction, shareAction, deleteAction])
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            self.showDimmedBackground()
            return nil
        }) { _ in
            self.removeDimmedBackground()
            return menu
        }
    }
    
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        
        animator?.addCompletion {
            self.removeDimmedBackground()
        }
    }
}

// MARK: - UISearchBarDelegate
extension TasksListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked with text: \(searchBar.text ?? "")")
        guard let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        viewModel?.loadData(searchText: text)
        table.reloadData()
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text did change: \(searchText)")
        if searchText.isEmpty {
            viewModel?.loadData(searchText: nil)
            table.reloadData()
        }
    }
}


