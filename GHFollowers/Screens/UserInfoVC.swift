//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

class UserInfoVC: UIViewController {

    let headerView = UIView()
    
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dimissVC))
        navigationItem.rightBarButtonItem = doneButton
        
        NetworkManager.shared.getUserInfo(for: userName) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    strongSelf.add(childVC: GFUserInfoHeaderVC(user: user), to: strongSelf.headerView)
                }
            case .failure(let error):
                break
            }
        }
        
        layoutUI()
    }
    
    func layoutUI() {
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180)
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
