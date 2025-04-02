//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/18/25.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {
    
    enum Section {
        case main
    }
    
    var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSearchController()
        configureViewController()
        getFollowers(username: username, page: page)
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
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
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search followers..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    /// Fetches followers for a specified username with pagination support
    /// - Parameters:
    ///   - username: The GitHub username to fetch followers for
    ///   - page: The page number to fetch (pagination, starts at 1)
    func getFollowers(username: String, page: Int) {
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
    /// - Parameter followers: Array of follower objects returned from the API
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
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    /// Handles the action when the Add button is tapped
    /// - Note: This function adds the current user to favorites by retrieving their information and storing it in the persistence layer
    @objc func addButtonTapped() {
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
    /// - Parameter user: The user to be added to favorites
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

extension FollowerListVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
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

extension FollowerListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased())}
        updateData(on: filteredFollowers)
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

extension FollowerListVC: UserInfoVCDelegate {
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
