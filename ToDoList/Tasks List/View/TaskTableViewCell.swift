//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Анастасия Ахановская on 14.11.2024.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    // MARK: - GUI Variables
    private lazy var checkboxImageView: UIImageView = {
        let view = UIImageView()
        view.image = State.uncomplete.image
        view.tintColor = .brightYellow
        view.contentMode = .center
        return view
    }()
    
    private lazy var boxView: UIView = {
        let view = UIView()
        view.backgroundColor = .softBlack
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .stroke
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = State.uncomplete.color
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textColor = State.uncomplete.color
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .stroke
        return label
    }()
    
    // MARK: - Properties
    static let reuseID = "TaskTableViewCell"
    
    let dateFormatter = DateFormatter()
    
    enum State {
        case complete, uncomplete
        
        var image: UIImage {
            switch self {
            case .complete:
                return UIImage.checkmark
            case .uncomplete:
                return UIImage(systemName: "circlebadge") ?? UIImage.add
            }
        }
        
        var color: UIColor {
            switch self {
            case .complete:
                return .stroke
            case .uncomplete:
                return .softWhite
            }
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with task: UserTask) {
        titleLabel.text = task.toDo
        descriptionLabel.text = task.toDoDescription ?? task.toDo
        
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: task.date ?? Date())
        
        checkboxImageView.image = task.isCompleted ? State.complete.image : State.uncomplete.image
        
        if task.isCompleted {
            titleLabel.attributedText = strikeText(strike: titleLabel.text ?? "")
            titleLabel.textColor = .stroke
            
            descriptionLabel.attributedText = strikeText(strike: descriptionLabel.text ?? "")
            descriptionLabel.textColor = .stroke
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        
        titleLabel.textColor = State.uncomplete.color
        descriptionLabel.textColor = State.uncomplete.color
    }
}

// MARK: - Private Methods
private extension TaskTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .softBlack
        
        contentView.addSubview(boxView)
        boxView.addSubviews([titleLabel, descriptionLabel, dateLabel, checkboxImageView, separatorView])
        
        setupConstraints()
    }
    
    func setupConstraints() {
        boxView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        checkboxImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalTo(boxView.snp.top).inset(8)
            make.leading.equalTo(boxView.snp.leading).inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(boxView.snp.top).inset(8)
            make.leading.equalTo(boxView.snp.leading).inset(52)
            make.trailing.equalTo(boxView.snp.trailing).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(boxView.snp.leading).inset(52)
            make.trailing.equalTo(boxView.snp.trailing).inset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.leading.equalTo(boxView.snp.leading).inset(52)
            make.trailing.equalTo(boxView.snp.trailing).inset(20)
            make.bottom.equalTo(boxView.snp.bottom).inset(12)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalTo(boxView.snp.leading).inset(20)
            make.trailing.equalTo(boxView.snp.trailing).inset(20)
            make.height.equalTo(1)
        }
    }
    
    func strikeText(strike : String) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: strike)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
