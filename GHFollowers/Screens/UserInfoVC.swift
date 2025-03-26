//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

class UserInfoVC: UIViewController {

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
                print(user)
            case .failure(let error):
                break
            }
        }
    }
    
    @objc func dimissVC() {
        dismiss(animated: true)
    }
}
