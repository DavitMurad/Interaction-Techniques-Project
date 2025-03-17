//
//  GazingTableViewCell.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 09.03.25.
//

import UIKit


class GazingTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24, weight: .medium) 
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI()
        }
        
        private func setupUI() {
            contentView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
        
        func configure(text: String, isSelected: Bool) {
            titleLabel.text = text
            
            if isSelected {
                contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
                titleLabel.textColor = .systemBlue
            } else {
                contentView.backgroundColor = .clear
                titleLabel.textColor = .label
            }
        }
        
        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            
            if highlighted {
                contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            } else if titleLabel.textColor != .systemBlue {
                contentView.backgroundColor = .clear
            }
        }
}

