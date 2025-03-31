//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/24/25.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    
    /// The reuse identifier for table view cell registration.
    static let reuseID = "FollowerCell"
    
    // MARK: - UI Components
    
    /// The avatar image view displaying the user's GitHub profile picture.
    let avatarImageView = GFAvatarImageView(frame: .zero)
    
    /// The label displaying the GitHub username.
    let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Data Population
    
    /// Updates the cell's UI with the provided follower data.
    /// - Parameter favorite: The `Follower` model containing user data to display.
    func set(follower: Follower) {
        usernameLabel.text = follower.login
        downloadAvatarImage(from: follower.avatarUrl)
    }
    
    /// Downloads and sets the avatar image from the given URL.
    /// - Parameter urlString: The URL string for the avatar image.
    private func downloadAvatarImage(from urlString: String) {
        NetworkManager.shared.downloadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }
    }
}
