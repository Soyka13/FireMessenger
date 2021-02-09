//
//  ConversationsTableViewCell.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 11.11.2020.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {
    
    public static let identifier = "ConversationsTableViewCell"
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userNameLabel.frame = CGRect(x: 10, y: 10, width: (contentView.width - 20), height: (contentView.height - 20)/2)
        userMessageLabel.frame =  CGRect(x: 10, y: userNameLabel.bottom + 10, width: (contentView.width - 20), height: (contentView.height - 20)/2)
        
    }
    
    public func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
    }
    
}
