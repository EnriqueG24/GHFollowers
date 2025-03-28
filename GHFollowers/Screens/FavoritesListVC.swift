//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/17/25.
//

import UIKit

class FavoritesListVC: UIViewController {

    let tableView = UITableView()
    var favorites: [Follower] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }

    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    func getFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let favorites):
                if favorites.isEmpty { 
                    strongSelf.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen.", in: strongSelf.view)
                } else {
                    strongSelf.favorites = favorites
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                        strongSelf.view.bringSubviewToFront(strongSelf.tableView)
                    }
                }
            case .failure(let error):
                strongSelf.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }   
    }
}

extension FavoritesListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)
        return cell 
    }
}   
