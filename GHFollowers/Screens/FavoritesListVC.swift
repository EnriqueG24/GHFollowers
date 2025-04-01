//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/17/25.
//

import UIKit

/// A view controller that displays and manages a list of favorite GitHub followers.
///
/// This class provides functionality to:
/// - Display a list of favorited GitHub users
/// - Remove favorites via swipe-to-delete
/// - Navigate to a follower's profile
/// - Show an empty state when no favorites exist
///
/// ## Overview
/// The `FavoritesListVC` integrates with `PersistenceManager` to persist favorites between app launches.
/// It inherits from `GFDataLoadingVC` to provide common loading and alert functionality.
final class FavoritesListVC: GFDataLoadingVC {
    
    // MARK: - Properties
    
    /// The table view that displays the list of favorites.
    private let tableView = UITableView()
    
    /// The array of favorite followers to display.
    private var favorites: [Follower] = []
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    // MARK: - Configuration
    
    /// Configures the view controller's basic appearance and navigation properties.
    ///
    /// Sets up:
    /// - Background color
    /// - Navigation title
    /// - Large title preference
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// Configures the table view's layout and properties.
    ///
    /// This method:
    /// - Adds the table view to the view hierarchy
    /// - Sets up auto-layout constraints
    /// - Registers the cell class
    /// - Configures row height and delegates
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    // MARK: - Data Handling
    
    /// Retrieves favorite followers from persistent storage and updates the UI.
    ///
    /// This method:
    /// - Fetches favorites using `PersistenceManager`
    /// - Handles success/failure cases
    /// - Updates UI on the main thread
    ///
    /// - Note: Shows an empty state view if no favorites exist, otherwise displays the favorites list.
    func getFavorites() {
        showLoadingView()
        
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let favorites):
                self.handleRetrievedFavorites(favorites)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentGFAlert(
                        title: "Something went wrong",
                        message: error.rawValue,
                        buttonTitle: "Ok"
                    )
                }
            }
        }
    }
    
    /// Processes retrieved favorites and updates the UI accordingly.
    ///
    /// - Parameter favorites: The array of favorite followers retrieved from persistence.
    ///
    /// If the favorites array is empty, shows an empty state view. Otherwise, updates
    /// the table view with the retrieved favorites.
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
    
    /// Returns the number of rows in the favorites table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    /// Configures and returns a cell for the specified index path.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)
        return cell
    }
    
    /// Handles selection of a favorite, pushing the follower list view controller.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destinationVC = FollowerListVC(username: favorite.login)
        
        navigationController?.pushViewController(destinationVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Handles swipe-to-delete functionality for favorites.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            
            guard let error = error else {
                // Update local data and UI
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                
                // Show empty state if last item was deleted
                if self.favorites.isEmpty {
                    self.showEmptyStateView(
                        with: "No Favorites?\nAdd one on the follower screen.",
                        in: self.view
                    )
                }
                return
            }
            
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}
