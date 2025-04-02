//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/18/25.
//

import UIKit

/// A view controller that displays a paginated grid of a GitHub user's followers.
///
/// This view controller handles:
/// - Fetching and displaying followers with pagination
/// - Searching/filtering followers
/// - Adding users to favorites
/// - Handling empty states and loading states
/// - Navigation to user detail screens
///
/// The view uses a collection view with diffable data source for efficient updates
/// and supports modern iOS patterns like content unavailable configurations.
class FollowerListVC: GFDataLoadingVC {
    
    // MARK: - Types
    
    /// Section identifiers for the collection view's diffable data source
    enum Section {
        case main
    }
    
    // MARK: - Properties
    
    /// The GitHub username whose followers are being displayed
    var username: String!
    
    /// Complete list of followers fetched from the API
    private var followers: [Follower] = []
    
    /// Filtered subset of followers when search is active
    private var filteredFollowers: [Follower] = []
    
    /// Current page number for pagination (starts at 1)
    private var page = 1
    
    /// Flag indicating whether more followers are available to fetch
    private var hasMoreFollowers = true
    
    /// Flag indicating whether a search is currently active
    private var isSearching = false
    
    /// Flag indicating whether a pagination request is in progress
    private var isLoadingMoreFollowers = false
    
    /// The collection view displaying the followers grid
    private var collectionView: UICollectionView!
    
    /// Diffable data source for the followers collection view
    private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    // MARK: - Initialization
    
    /// Creates a new follower list view controller for the specified username
    /// - Parameter username: The GitHub username whose followers will be displayed
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        configureSearchController()
        configureDataSource()
        getFollowers(username: username, page: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - UI Configuration
    
    /// Configures the base view controller properties and navigation bar
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    /// Configures the collection view with a three-column layout optimized for follower avatars
    ///
    /// Sets up:
    /// - Collection view layout
    /// - Cell registration
    /// - Delegate connections
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    /// Configures the search controller for filtering followers by username
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search followers..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    /// Configures the diffable data source for the collection view
    ///
    /// This sets up the cell provider that configures each follower cell with its data
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    /// Updates the content unavailable configuration based on the current state.
    ///
    /// This method configures the empty state UI that appears when:
    /// - There are no followers to display
    /// - A search returns no results
    ///
    /// - Parameter state: The current content unavailable configuration state
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if followers.isEmpty && !isLoadingMoreFollowers {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = .init(systemName: "person.slash")
            config.text = "No Followers"
            config.secondaryText = "This user has no followers. Go follow them!"
            contentUnavailableConfiguration = config
        } else if isSearching && filteredFollowers.isEmpty {
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    
    // MARK: - Data Loading
    
    /// Fetches followers for a specified username with pagination support
    ///
    /// - Parameters:
    ///   - username: The GitHub username to fetch followers for
    ///   - page: The page number to fetch (pagination, starts at 1)
    ///
    /// - Note: Each page contains up to 100 followers. When fewer than 100 followers
    ///         are returned, `hasMoreFollowers` is set to false.
    private func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                updateUI(with: followers)
                dismissLoadingView()
                isLoadingMoreFollowers = false
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Bad stuff happened", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
                isLoadingMoreFollowers = false
                dismissLoadingView()
            }
        }
    }
    
    /// Processes followers data after a successful network request
    ///
    /// - Parameter followers: Array of follower objects returned from the API
    ///
    /// This method:
    /// - Updates the pagination state
    /// - Appends new followers to the collection
    /// - Updates empty state configuration
    /// - Refreshes the UI with the updated data
    private func updateUI(with followers: [Follower]) {
        // Check if we've reached the end of available data
        if followers.count < 100 {
            hasMoreFollowers = false
        }
        
        // Add new followers to our collection
        self.followers.append(contentsOf: followers)
        
        // Show empty state if there are no followers
        setNeedsUpdateContentUnavailableConfiguration()
        
        // Update UI with appropriate data source
        updateData(on: isSearching ? filteredFollowers : self.followers)
    }
    
    /// Updates the collection view with the provided follower data
    ///
    /// - Parameter followers: The array of followers to display
    ///
    /// This method applies a new snapshot to the diffable data source,
    /// which automatically handles animating changes to the UI.
    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    // MARK: - User Actions
    
    /// Handles the action when the Add button is tapped
    ///
    /// This function adds the current user to favorites by:
    /// 1. Fetching the user's full profile information
    /// 2. Converting it to a Follower object for storage
    /// 3. Storing it in the persistence layer
    @objc private func addButtonTapped() {
        showLoadingView()
        
        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                addUserToFavorites(user)
                dismissLoadingView()
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
                dismissLoadingView()
            }
        }
    }
    
    /// Adds a user to favorites using the PersistenceManager
    ///
    /// - Parameter user: The user to be added to favorites
    ///
    /// This method converts the User object to a Follower object (for consistency in storage)
    /// and saves it via the PersistenceManager, displaying appropriate feedback to the user.
    private func addUserToFavorites(_ user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self else { return }
            
            guard let error else {
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Success!", message: "You have successfully favorites this user!", buttonTitle: "Hooray!")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FollowerListVC: UICollectionViewDelegate {
    
    /// Handles pagination when the user scrolls to the bottom of the followers list.
    ///
    /// This method detects when the user has scrolled to the bottom of the content and
    /// automatically fetches the next page of followers if available.
    ///
    /// - Parameters:
    ///   - scrollView: The scroll view that triggered the event
    ///   - decelerate: Boolean indicating whether the scroll view will continue moving after the drag ends
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // Check if user has scrolled to the bottom of the content
        let bottomThreshold: CGFloat = 100 // Buffer to start loading earlier
        if offsetY > contentHeight - height - bottomThreshold {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    /// Handles selection of a follower cell
    ///
    /// When a follower is selected, this method presents a detail view controller
    /// showing that user's information.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view containing the selected item
    ///   - indexPath: The index path of the selected item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let destinationVC = UserInfoVC()
        destinationVC.userName = follower.login
        destinationVC.delegate = self
        
        let navController = UINavigationController(rootViewController: destinationVC)
        present(navController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension FollowerListVC: UISearchResultsUpdating {
    
    /// Handles search filtering of the followers list.
    ///
    /// This method is called whenever the search text changes. It filters the followers
    /// list based on the search text and updates the UI accordingly.
    ///
    /// - Parameter searchController: The search controller containing the search query
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            // Reset search state when search text is empty
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            setNeedsUpdateContentUnavailableConfiguration()
            return
        }
        
        isSearching = true
        
        // Convert search text to lowercase once for performance
        let lowercasedFilter = filter.lowercased()
        
        // Filter followers based on login containing the search text
        filteredFollowers = followers.filter {
            $0.login.lowercased().contains(lowercasedFilter)
        }
        
        updateData(on: filteredFollowers)
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

// MARK: - UserInfoVCDelegate

extension FollowerListVC: UserInfoVCDelegate {
    
    /// Handles requests to show followers for a different user
    ///
    /// This delegate method is called when the user navigates to a different user
    /// from the user info screen and chooses to view that user's followers.
    ///
    /// - Parameter username: The username of the new user whose followers should be displayed
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page = 1
        
        followers.removeAll()
        filteredFollowers.removeAll()
        updateData(on: followers)
        getFollowers(username: username, page: page)
    }
}
