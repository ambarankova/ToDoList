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
        
        setupConstraints()
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
    
    @objc private func hideKeyboard() {
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
//        if var task = viewModel.sections[indexPath.section].items[indexPath.row] as? TaskObject {
//            task.isCompleted.toggle()
//            viewModel.sections[indexPath.section].items[indexPath.row] = task
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
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

