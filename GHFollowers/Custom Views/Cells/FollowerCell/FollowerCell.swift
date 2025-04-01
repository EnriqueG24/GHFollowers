//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/24/25.
//

import UIKit
import SwiftUI

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

    /// Configures the cell's UI with the given follower data.
    /// - Parameter follower: A `Follower` model containing the user's information.
    /// - Note: On iOS 16 and later, this method uses `UIHostingConfiguration` to display `FollowerView`.
    ///         On earlier versions, it manually sets the `usernameLabel` and loads the avatar image.
    func set(follower: Follower) {
        if #available(iOS 16.0, *) {
            contentConfiguration = UIHostingConfiguration {
                FollowerView(follower: follower)
            }
        } else {
            usernameLabel.text = follower.login
            avatarImageView.downloadImage(fromURL: follower.avatarUrl)
        }
    }

}
