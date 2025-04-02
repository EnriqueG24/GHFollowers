//
//  PersistenceManager.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/27/25.
//

import Foundation

/// Defines the type of action to perform on favorites data.
///
/// - `add`: Adds a follower to favorites.
/// - `remove`: Removes a follower from favorites.
enum PersistenceActionType {
    case add
    case remove
}

/// Manages the persistence of user favorites using UserDefaults.
///
/// This singleton-like manager provides methods to add, remove, retrieve,
/// and save favorite followers to the device's local storage.
enum PersistenceManager {
    
    // MARK: - Properties
    
    /// The standard UserDefaults instance used for data persistence.
    static private let defaults = UserDefaults.standard
    
    /// Keys used for storing data in UserDefaults.
    enum Keys {
        static let favorites = "favorites"
    }
    
    // MARK: - Public Methods
    
    /// Updates the favorites list by adding or removing a follower.
    ///
    /// This method retrieves the current list of favorites, performs the specified action,
    /// and then saves the updated list back to UserDefaults.
    ///
    /// - Parameters:
    ///   - favorite: The follower to add or remove.
    ///   - actionType: The type of action to perform (add or remove).
    ///   - completed: A completion handler that returns an optional error if the operation fails.
    ///
    /// - Note: When adding a follower that already exists in favorites, the method will return
    ///         a `.alreadyInFavorites` error through the completion handler.
    static func updateWith(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (GFError?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(var favorites):
                switch actionType {
                case .add:
                    guard !favorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    favorites.append(favorite)
                    
                case .remove:
                    favorites.removeAll { $0.login == favorite.login }
                }
                
                completed(save(favorites: favorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    /// Retrieves the list of favorite followers from UserDefaults.
    ///
    /// - Parameter completed: A completion handler that returns either an array of followers
    ///                        or an error if the retrieval fails.
    ///
    /// - Note: If no favorites exist yet, this method returns an empty array.
    static func retrieveFavorites(completed: @escaping (Result<[Follower], GFError>) -> Void) {
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    /// Saves the provided array of followers to UserDefaults.
    ///
    /// - Parameter favorites: The array of followers to save.
    /// - Returns: An optional `GFError` if the operation fails, otherwise `nil`.
    ///
    /// - Note: This method uses JSONEncoder to convert the array to Data before saving.
    static func save(favorites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
}
