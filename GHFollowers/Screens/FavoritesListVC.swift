//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/17/25.
//

import UIKit

class FavoritesListVC: GFDataLoadingVC {

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
    
    /// Retrieves and displays favorite followers from persistent storage
    /// - Note: Updates UI to show either favorites list or empty state view based on results
    func getFavorites() {
       PersistenceManager.retrieveFavorites { [weak self] result in
           guard let strongSelf = self else { return }
           
           switch result {
           case .success(let favorites):
               strongSelf.handleRetrievedFavorites(favorites)
           case .failure(let error):
               strongSelf.presentGFAlert(
                   title: "Something went wrong",
                   message: error.rawValue,
                   buttonTitle: "Ok"
               )
           }
       }
    }

    /// Processes retrieved favorites and updates UI accordingly
    /// - Parameter favorites: The array of favorite followers retrieved from persistence
    private func handleRetrievedFavorites(_ favorites: [Follower]) {
       if favorites.isEmpty {
           showEmptyStateView(
               with: "No Favorites?\nAdd one on the follower screen.",
               in: self.view
           )
       } else {
           self.favorites = favorites
           DispatchQueue.main.async {
               self.tableView.reloadData()
               self.view.bringSubviewToFront(self.tableView)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destinationVC = FollowerListVC(username: favorite.login)
        
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let strongSelf = self else { return }
            
            guard let error = error else {
                strongSelf.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            strongSelf.presentGFAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}
