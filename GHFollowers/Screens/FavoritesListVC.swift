//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/17/25.
//

import UIKit

/// A view controller that displays and manages a list of favorite GitHub followers.
///
/// This view controller provides the following functionality:
/// - Displays a list of favorited GitHub users in a table view
/// - Supports removing favorites via swipe-to-delete gestures
/// - Navigates to a follower's profile when a cell is selected
/// - Shows an empty state view when no favorites exist
/// - Persists changes using `PersistenceManager`
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
    
    /// Updates the content unavailable configuration based on the current favorites state.
    ///
    /// This method automatically shows an empty state when the favorites array is empty,
    /// and hides it when favorites exist. The empty state includes:
    /// - A star icon (from SF Symbols)
    /// - A primary text "No Favorites"
    /// - Secondary instructional text
    ///
    /// - Parameter state: The current state of the content unavailable configuration.
    ///
    /// - Note: This overrides the parent class implementation to provide custom empty state styling.
    /// - Important: Called automatically by the system when the favorites array changes.
    ///   Trigger manually using `setNeedsUpdateContentUnavailableConfiguration()`.
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if favorites.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = .init(systemName: "star")
            config.text = "No favorites"
            config.secondaryText = "Add a favorite on the follower list screen"
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    
    // MARK: - Configuration
    
    /// Configures the view controller's basic appearance and navigation properties.
    ///
    /// This method:
    /// - Sets the background color to match the system background
    /// - Configures the navigation title
    /// - Enables large titles in the navigation bar
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    /// Configures the table view's layout and properties.
    ///
    /// This method:
    /// - Adds the table view to the view hierarchy
    /// - Sets the table view to fill the available space
    /// - Registers the `FavoriteCell` class for cell reuse
    /// - Sets the row height to 80 points
    /// - Assigns the delegate and data source
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
    /// This asynchronous method:
    /// 1. Shows a loading view
    /// 2. Attempts to retrieve favorites from `PersistenceManager`
    /// 3. Updates the UI on the main thread:
    ///    - On success: Displays the retrieved favorites
    ///    - On failure: Shows an error alert
    func getFavorites() {
        showLoadingView()
        
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self else { return }
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
    
    /// Updates the UI with the retrieved favorites.
    ///
    /// - Parameter favorites: The array of `Follower` objects to display.
    ///
    /// This method:
    /// - Updates the local favorites array
    /// - Triggers the empty state view update if needed
    /// - Reloads the table view data on the main thread
    private func handleRetrievedFavorites(_ favorites: [Follower]) {
        self.favorites = favorites
        setNeedsUpdateContentUnavailableConfiguration()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.view.bringSubviewToFront(self.tableView)
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
    ///
    /// - Important: This method persists the deletion using `PersistenceManager`.
    /// - Note: Shows an error alert if the persistence operation fails.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self else { return }
            
            guard let error else {
                // Update local data and UI
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                
                // Show empty state if last item was deleted
                setNeedsUpdateContentUnavailableConfiguration()
                return
            }
            
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}
