//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

class UserInfoVC: UIViewController {

    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    var itemViews: [UIView] = []
    
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        getUserInfo()
        layoutUI()
    }
    
    fileprivate func getUserInfo() {
        NetworkManager.shared.getUserInfo(for: userName) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    strongSelf.add(childVC: GFUserInfoHeaderVC(user: user), to: strongSelf.headerView)
                    strongSelf.add(childVC: GFRepoItemVC(user: user), to: strongSelf.itemViewOne)
                    strongSelf.add(childVC: GFFollowerItemVC(user: user), to: strongSelf.itemViewTwo)
                }
            case .failure(let error):
                self?.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dimissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView, itemViewOne, itemViewTwo]
        
        for itemView in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    @objc func dimissVC() {
        dismiss(animated: true)
    }
}
