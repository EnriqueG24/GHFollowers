//
//  GFUserInfoHeaderVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

/// A view controller that displays user profile information in a header format.
///
/// This component shows the user's avatar, username, name, location, and bio information
/// in a standardized layout designed to be embedded within other view controllers.
class GFUserInfoHeaderVC: UIViewController {
    
    // MARK: - UI Components
    
    /// Image view for displaying the user's avatar.
    private let avatarImageView = GFAvatarImageView(frame: .zero)
    
    /// Label displaying the user's username in a prominent style.
    private let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 34)
    
    /// Label displaying the user's real name.
    private let nameLabel = GFSecondaryTitleLabel(fontSize: 18)
    
    /// Image view showing the location icon.
    private let locationImageView = UIImageView()
    
    /// Label displaying the user's location.
    private let locationLabel = GFSecondaryTitleLabel(fontSize: 18)
    
    /// Label displaying the user's bio information.
    private let bioLabel = GFBodyLabel(textAlignment: .left)
    
    // MARK: - Properties
    
    /// The user model containing profile information to display.
    private let user: User
    
    // MARK: - Layout Constants
    
    private enum LayoutMetrics {
        /// Standard padding around components.
        static let padding: CGFloat = 20
        
        /// Padding between text and images.
        static let textImagePadding: CGFloat = 12
        
        /// Small spacing between related elements.
        static let smallSpacing: CGFloat = 5
        
        /// Avatar image dimensions.
        static let avatarSize: CGFloat = 90
        
        /// Username label height.
        static let usernameLabelHeight: CGFloat = 38
        
        /// Standard text element height.
        static let standardLabelHeight: CGFloat = 20
        
        /// Bio label height.
        static let bioLabelHeight: CGFloat = 60
        
        /// Icon size for small icons like location.
        static let iconSize: CGFloat = 20
        
        /// Number of lines for bio text.
        static let bioNumberOfLines = 3
    }
    
    // MARK: - Initialization
    
    /// Creates a new user info header view controller with the specified user data.
    ///
    /// - Parameter user: The user model containing profile information to display.
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Interface Builder initialization is not supported.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    /// Sets up the view when loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureLayout()
        configureUIElements()
    }
    
    // MARK: - Configuration Methods
    
    /// Configures UI elements with user data.
    private func configureUIElements() {
        // Download and set avatar image
        avatarImageView.downloadImage(fromURL: user.avatarUrl)
        
        // Configure text elements
        usernameLabel.text = user.login
        nameLabel.text = user.name ?? ""
        locationLabel.text = user.location ?? "No Location"
        
        // Configure bio with fallback and limited lines
        bioLabel.text = user.bio ?? "No Bio"
        bioLabel.numberOfLines = LayoutMetrics.bioNumberOfLines
        
        // Configure location icon
        locationImageView.image = SFSymbols.location
        locationImageView.tintColor = .secondaryLabel
        locationImageView.contentMode = .scaleAspectFit
    }
    
    /// Adds all subviews to the view hierarchy.
    private func configureSubviews() {
        view.addSubviews(avatarImageView, usernameLabel, nameLabel, locationImageView, locationLabel, bioLabel)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Sets up the auto layout constraints for all elements.
    private func configureLayout() {
        NSLayoutConstraint.activate([
            // Avatar image constraints
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutMetrics.padding),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: LayoutMetrics.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: LayoutMetrics.avatarSize),
            
            // Username label constraints
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: LayoutMetrics.textImagePadding),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usernameLabel.heightAnchor.constraint(equalToConstant: LayoutMetrics.usernameLabelHeight),
            
            // Name label constraints
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: LayoutMetrics.textImagePadding),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: LayoutMetrics.standardLabelHeight),
            
            // Location icon constraints
            locationImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: LayoutMetrics.textImagePadding),
            locationImageView.widthAnchor.constraint(equalToConstant: LayoutMetrics.iconSize),
            locationImageView.heightAnchor.constraint(equalToConstant: LayoutMetrics.iconSize),
            
            // Location label constraints
            locationLabel.centerYAnchor.constraint(equalTo: locationImageView.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: LayoutMetrics.smallSpacing),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationLabel.heightAnchor.constraint(equalToConstant: LayoutMetrics.standardLabelHeight),
            
            // Bio label constraints
            bioLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: LayoutMetrics.textImagePadding),
            bioLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bioLabel.heightAnchor.constraint(equalToConstant: LayoutMetrics.bioLabelHeight)
        ])
    }
}
