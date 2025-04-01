//
//  FavoriteCell.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/28/25.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    /// The reuse identifier for table view cell registration.
    static let reuseID = "FavoriteCell"
    
    // MARK: - UI Components
    
    /// The avatar image view displaying the user's GitHub profile picture.
    private let avatarImageView = GFAvatarImageView(frame: .zero)
    
    /// The label displaying the GitHub username.
    private let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 26)
    
    /// The URL of the avatar image currently being loaded
    private var currentAvatarURL: String?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        
        accessoryType = .disclosureIndicator
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
    
    // MARK: - Data Population
    
    /// Updates the cell's UI with the provided follower data.
    /// - Parameter favorite: The `Follower` model containing user data to display.
    func set(favorite: Follower) {
        usernameLabel.text = favorite.login
        currentAvatarURL = favorite.avatarUrl
        avatarImageView.image = avatarImageView.placeholderImage
        
        Task {
            if let image = await NetworkManager.shared.downloadImage(from: favorite.avatarUrl),
               currentAvatarURL == favorite.avatarUrl {
                avatarImageView.image = image
            }
        }
    }
}
