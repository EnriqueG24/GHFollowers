//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

/// A delegate protocol for handling follower requests from the UserInfoVC
protocol UserInfoVCDelegate: AnyObject {
    
    /// Notifies the delegate that followers were requested for a specific username
    /// - Parameter username: The GitHub username to fetch followers for
    func didRequestFollowers(for username: String)
}

class UserInfoVC: UIViewController {
    
    // MARK: - UI Properties
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    // MARK: - Properties
    var userName: String!
    weak var delegate: UserInfoVCDelegate!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureScrollView()
        getUserInfo()
        layoutUI()
    }
    
    func getUserInfo() {
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: userName)
                configureUIElements(with: user)
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
            }
        }
    }
    
    // MARK: - Configuration
    
    /// Configures all UI elements with the user data
    /// - Parameter user: The User model containing the data to display
    private func configureUIElements(with user: User) {
        add(childVC: GFUserInfoHeaderVC(user: user), to: headerView)
        add(childVC: GFRepoItemVC(user: user, delegate: self), to: itemViewOne)
        add(childVC: GFFollowerItemVC(user: user, delegate: self), to: itemViewTwo)
        dateLabel.text = "GitHub since \(user.createdAt.convertToMonthYearFormat())"
    }
    
    /// Configures the scroll view and its content view
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    /// Configures the basic view controller settings
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissVC))
    }
    
    /// Lays out all the UI elements in the content view
    func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        
        for itemView in itemViews {
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helper Methods
    
    /// Adds a child view controller to a container view
    /// - Parameters:
    ///   - childVC: The child view controller to add
    ///   - containerView: The container view that will host the child's view
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    /// Dismisses the view controller
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

// MARK: - GFRepoItemVCDelegate

extension UserInfoVC: GFRepoItemVCDelegate {
    func didTapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlert(
                title: "Invalid URL",
                message: "The url attached to this user is invalid",
                buttonTitle: "Ok")
            return
        }
        
        presentSafariVC(with: url)
    }
}

// MARK: - GFFollowerItemVCDelegate

extension UserInfoVC: GFFollowerItemVCDelegate {
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGFAlert(
                title: "No followers",
                message: "This user has no followers. What a shame",
                buttonTitle: "Ok")
            return
        }
        
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }
}
