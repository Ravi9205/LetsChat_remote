//
//  ConversationTableCell.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 08/04/22.
//

import UIKit
import SDWebImage

class ConversationTableCell: UITableViewCell {
    
    static let  identifier = "ConversationTableCell"
    
    private let userImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    
    private let userMessageLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
        
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10.0,
                                     y: 10.0,
                                     width: 100.0,
                                     height: 100.0)
        userNameLabel.frame = CGRect(x: userImageView.right+10,
                                     y: 10.0,
                                     width: contentView.width-20 - userImageView.width,
                                     height: (contentView.height-20)/2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right+10,
                                        y: userNameLabel.bottom+10,
                                        width: contentView.width-20 - userImageView.width,
                                        height: (contentView.height-20)/2)
        
    }
    
    public func configure(with model:Conversation){
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let imagePath = "images/\(model.otherUserEmail)_profile_picture_png"
        StorageManager.shared.downloadURL(path: imagePath) {[weak self] result in
            switch result {
                case .success( let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed:  nil)
                }
            case .failure(let error):
                print("Failed to download Images\(error)")
            }
        }
        
    }
}

