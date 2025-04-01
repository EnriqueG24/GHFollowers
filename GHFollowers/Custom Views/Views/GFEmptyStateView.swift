//
//  GFEmptyStateView.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/24/25.
//

import UIKit

class GFEmptyStateView: UIView {
    
    // MARK: - Properties
    
    /// The label displaying the empty state message.
    private let messageLabel = GFTitleLabel(textAlignment: .center, fontSize: 28)
    
    /// The image view displaying the empty state logo.
    private let logoImageView = UIImageView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Creates an empty state view with the specified message.
    /// - Parameter message: The message to display in the empty state.
    convenience init(message: String) {
        self.init(frame: .zero)
        messageLabel.text = message
    }
    
    // MARK: - Configuration
    
    /// Configures the view hierarchy and layout.
    private func configure() {
        addSubviews(messageLabel, logoImageView)
        configureMessageLabel()
        configureLogoImageView()
    }
    
    /// Configures the message label appearance and constraints.
    private func configureMessageLabel() {
        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel
        
        let labelCenterYConstant: CGFloat = DeviceType.isiPhoneSE || DeviceType.isiPhone8Zoomed ? -80 : -150
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: labelCenterYConstant),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    /// Configures the logo image view appearance and constraints.
    private func configureLogoImageView() {
        logoImageView.image = Images.emptyStateLogo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoBottomConstant: CGFloat = DeviceType.isiPhoneSE || DeviceType.isiPhone8Zoomed ? 80 : 40
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 170),
            logoImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: logoBottomConstant)
        ])
    }
}
