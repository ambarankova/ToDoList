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
    
    private lazy var tableView: UITableView = {
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
        
        viewModel?.loadData()
    }
}

// MARK: - Private Methods
private extension TasksListViewController {
    func setupViewModel() {
        viewModel?.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func setupTableView() {
        tableView.register(TaskTableViewCell.self,
                           forCellReuseIdentifier: TaskTableViewCell.reuseID)
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupUI() {
        view.addSubviews([searchBar, tableView, titleLabel])
        view.backgroundColor = .softBlack
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(recognizer)
        
        tasksCount()
        setupConstraints()
        setupBars()
        setupContextMenu()
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupSearchBar(_ searchBar: UISearchBar) {
        searchBar.barTintColor = .clear
        
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
        let countLabel = UIBarButtonItem(title: "\(countOfTasks) tasks".localized,
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
    
    func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        tableView.addInteraction(interaction)
    }
    
    func tasksCount() {
        guard let VM = viewModel else { return }
        let allTasks = VM.getTasks()
        countOfTasks = allTasks.count
    }
    
    func createContextMenu(for task: TaskObject) -> UIMenu {
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                self.editTask()
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                print("Shared my task!")
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
                self.viewModel?.delete(task)
            }

            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    
    func editTask() {
        let editTaskViewController = EditTaskViewController()
        let viewModel = EditTaskViewModel()
        editTaskViewController.viewModel = viewModel
        navigationController?.pushViewController(editTaskViewController, animated: true)
    }
    
    @objc func addTask() {
        let newTaskViewController = NewTaskViewController()
        let viewModel = NewTaskViewModel()
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
        guard let task = viewModel?.sections[indexPath.section].items[indexPath.row] as? TaskObject,
              let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseID, for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        cell.configure(with: task)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var task = viewModel?.sections[indexPath.section].items[indexPath.row] as? TaskObject  {
            task.isCompleted.toggle()
            TaskPersistant.save(task)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TasksListViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
            let task = viewModel?.sections[indexPath.section].items[indexPath.row] // Достаем задачу по индексу

            // Создаём меню с действиями
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                // Действие для редактирования
                print("Edit task")
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                // Действие для поделиться
                print("Share task")
            }
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
                // Действие для удаления
                print("Delete task")
            }
            
            let menu = UIMenu(title: "", children: [editAction, shareAction, deleteAction])
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
                return menu
            })
        }

//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        guard let indexPath = tableView.indexPathForRow(at: location),
//              let task = viewModel?.sections[indexPath.section].items[indexPath.row] as? TaskObject else { return nil }
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
//            return self.createContextMenu(for: task)
//        })
//    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            guard let selectedCell = interaction.view as? UITableViewCell else { return }
            
            // Увеличиваем ячейку при сильном нажатии
            UIView.animate(withDuration: 0.3) {
                selectedCell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            
            // Затемняем фон при сильном нажатии
            showDimmedBackground()
        }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, didEndMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        guard let selectedCell = interaction.view as? UITableViewCell else { return }

        UIView.animate(withDuration: 0.3) {
            selectedCell.transform = CGAffineTransform.identity
        }

        removeDimmedBackground()
    }

    func showDimmedBackground() {
        dimmingView = UIView(frame: view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(dimmingView!)
    }

    func removeDimmedBackground() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }
}


// MARK: - UISearchBarDelegate
extension TasksListViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//        
//        viewModel.loadData(searchText: text)
//        searchBar.searchTextField.resignFirstResponder()
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            viewModel.loadData(searchText: nil)
//        }
//        
//        let recognizer = UITapGestureRecognizer(target: self,
//                                                action: #selector(hideKeyboard))
//        view.addGestureRecognizer(recognizer)
//    }
//    
//    @objc private func hideKeyboard() {
//        searchBar.searchTextField.resignFirstResponder()
//    }
}

