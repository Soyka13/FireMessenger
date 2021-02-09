//
//  NewConversationCell.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 12.11.2020.
//

import UIKit

class NewConversationCell: UITableViewCell {
    
    static let identifier = "NewConversationCell"
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        userNameLabel.frame = CGRect(x: 10,
                                     y: 20,
                                     width: contentView.width - 20,
                                     height: 50)
    }
    
    public func configure(with model: SearchResult) {
        userNameLabel.text = model.name

    }
    
}
