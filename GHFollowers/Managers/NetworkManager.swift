//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/21/25.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.github.com/users/"
    let cache = NSCache<NSString, UIImage>()
    
    /// This ensure there can only be on instance of it
    private init() {}
    
    func getFollowers(for username: String, page: Int, completed: @escaping (Result<[Follower], GFError>) -> Void) {
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completed(.success(followers))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func getUserInfo(for username: String, completed: @escaping (Result<User, GFError>) -> Void) {
        let endpoint = baseURL + "\(username)"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let user = try decoder.decode(User.self, from: data)
                completed(.success(user))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    /// Downloads an image from the specified URL string and manages caching.
    ///
    /// - Parameters:
    ///   - urlString: The URL string of the image to download
    ///   - completed: A closure called upon completion with the downloaded UIImage (or nil if download failed)
    ///
    /// This function first checks the cache for an existing image. If not found,
    /// it downloads the image asynchronously. The completion handler is called in these cases:
    /// 1. Immediately with cached image if available
    /// 2. With the downloaded image if successful
    /// 3. With nil if any error occurs during download or URL creation
    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        // Create cache key from the URL string
        let cacheKey = NSString(string: urlString)
        
        // Check cache for existing image
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        // Attempt to create URL from string
        guard let url = URL(string: urlString) else {
            return completed(nil)
        }
        
        // Create data task for downloading image
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Handle all possible error cases first
            guard error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data),
                  let self = self else {
                return DispatchQueue.main.async { completed(nil) }
            }
            
            // Store downloaded image in cache
            self.cache.setObject(image, forKey: cacheKey)
            
            // Update image on main thread
            DispatchQueue.main.async {
                completed(image)
            }
        }
        
        // Start the download task
        task.resume()
    }
}
