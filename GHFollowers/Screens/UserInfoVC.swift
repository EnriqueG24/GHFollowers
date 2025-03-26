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
    }
    
    @objc func dimissVC() {
        dismiss(animated: true)
    }
}
