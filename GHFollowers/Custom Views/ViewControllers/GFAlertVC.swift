//
//  GFAlertVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/20/25.
//

import UIKit

class GFAlertVC: UIViewController {
    
    // MARK: - UI Components
    
    /// The container view that holds all alert components
    let containerView = GFAlertContainerView()
    
    /// The title label displayed at the top of the alert
    let titleLabel = GFTitleLabel(textAlignment: .center, fontSize: 20)
    
    /// The message label displaying the alert's main content
    let messageLabel = GFBodyLabel(textAlignment: .center)
    
    /// The primary action button at the bottom of the alert
    let actionButton = GFButton(color: .systemPink, title: "Ok", systemImageName: "checkmark.circle")
    
    // MARK: - Properties
    
    /// The title text for the alert. Defaults to "Something went wrong" if nil.
    var alertTitle: String?
    
    /// The message text for the alert. Defaults to "Unable to complete request" if nil.
    var message: String?
    
    /// The text for the action button. Defaults to "Ok" if nil.
    var buttonTitle: String?
    
    /// The padding used for layout constraints
    private let padding: CGFloat = 20
    
    
    // MARK: - Initialization
    
    init(alertTitle: String? = nil, message: String? = nil, buttonTitle: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = alertTitle
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layoutUI()
    }
    
    // MARK: - Private Methods
    
    /// Configures the base view properties
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubviews(containerView, titleLabel, actionButton, messageLabel)
    }
    
    /// Sets up all layout constraints
    private func layoutUI() {
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureMessageLabel()
    }
    
    /// Configures constraints for the container view
    func configureContainerView() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    /// Configures the title label with text and constraints
    func configureTitleLabel() {
        titleLabel.text = alertTitle ?? "Something went wrong"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    /// Configures the action button with text, target, and constraints
    func configureActionButton() {
        actionButton.setTitle(buttonTitle ?? "Ok", for: .normal)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    /// Configures the message label with text and constraints
    func configureMessageLabel() {
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 4
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
        ])
    }
    
    // MARK: - Actions
    
    /// Dismisses the alert view controller
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}
