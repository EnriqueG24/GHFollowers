//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/21/25.
//

import UIKit

/// A singleton network manager responsible for handling GitHub API requests.
///
/// Use `NetworkManager.shared` to access the singleton instance.
/// The manager provides methods to fetch GitHub followers, user information, and download user avatars.
/// It includes caching for images to optimize network usage.
final class NetworkManager {
    
    // MARK: - Shared Instance
    
    /// The shared singleton instance of the NetworkManager.
    static let shared = NetworkManager()
    
    // MARK: - Properties
    
    /// The base URL for GitHub's user API endpoints.
    private let baseURL = "https://api.github.com/users/"
    
    /// Cache for storing downloaded user avatars to avoid repeated network requests.
    private let cache = NSCache<NSString, UIImage>()
    
    /// JSON decoder configured for GitHub's API response format.
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern.
    private init() {}
    
    
    // MARK: - Public Methods
    
    /// Fetches a list of followers for a specific GitHub user.
    /// - Parameters:
    ///   - username: The GitHub username to fetch followers for.
    ///   - page: The page number of results to fetch (GitHub paginates follower lists).
    /// - Returns: An array of ``Follower`` objects.
    /// - Throws: A ``GFError`` if any error occurs during the network request or data parsing.
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw GFError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do {
            return try decoder.decode([Follower].self, from: data)
        } catch {
            throw GFError.invalidData
        }
    }
    
    /// Fetches detailed information about a specific GitHub user.
    /// - Parameter username: The GitHub username to fetch information for.
    /// - Returns: A ``User`` object containing the user's details.
    /// - Throws: A ``GFError`` if any error occurs during the network request or data parsing.
    func getUserInfo(for username: String) async throws -> User {
        let endpoint = baseURL + "\(username)"
        
        guard let url = URL(string: endpoint) else {
            throw GFError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do {
            return try decoder.decode(User.self, from: data)
        } catch {
            throw GFError.invalidData
        }
    }
    
    /// Downloads and caches an image from the specified URL string.
    ///
    /// This method implements a two-level optimization:
    /// 1. **Memory Cache**: First checks the in-memory cache (``NSCache``) for the image
    /// 2. **Network Fetch**: Only downloads from network if not found in cache
    ///
    /// The cache uses the URL string as its key (converted to ``NSString``) and stores the decoded ``UIImage``.
    /// Cached images will be automatically purged under memory pressure, following ``NSCache``'s eviction policy.
    ///
    /// ## Usage Example
    /// ```swift
    /// let image = await NetworkManager.shared.downloadImage(from: avatarURL)
    /// avatarImageView.image = image
    /// ```
    ///
    /// - Parameter urlString: The URL string of the image to download.
    ///   - Must be a valid URL string that ``URL`` can initialize
    ///   - Should typically be an HTTPS URL pointing to an image resource
    /// - Returns: A ``UIImage`` if:
    ///   - The image exists in cache, or
    ///   - The download succeeds and the data can be converted to an image
    /// - Returns `nil` if:
    ///   - The URL string is invalid
    ///   - The network request fails
    ///   - The downloaded data isn't a valid image
    func downloadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        
        // Check cache first - return immediately if found
        if let image = cache.object(forKey: cacheKey) {
            return image
        }
        
        // Validate URL before attempting download
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            // Perform network request
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Convert data to UIImage
            guard let image = UIImage(data: data) else { return nil }
            
            // Cache the image before returning
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            // Silently fail (return nil) for all errors since this is often
            // used for non-critical UI elements like avatars
            return nil
        }
    }
}
