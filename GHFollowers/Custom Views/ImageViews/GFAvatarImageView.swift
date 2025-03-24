//
//  GFAvatarImageView.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/24/25.
//

import UIKit

class GFAvatarImageView: UIImageView {
    
    let cache = NetworkManager.shared.cache
    let placeholderImage = UIImage(named: "avatar-placeholder")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Downloads an image from the specified URL string and manages caching.
    ///
    /// This function first checks the cache for an existing image. If not found,
    /// it downloads the image asynchronously, stores it in cache, and updates the view.
    func downloadImage(from urlString: String) {
        
        // Create cache key from the URL string
        let cacheKey = NSString(string: urlString)
        
        // Check cache for existing image
        if let image = cache.object(forKey: cacheKey) {
            // If found in cache, set image and return early
            self.image = image
            return
        }
        
        // Attempt to create URL from string, return if invalid
        guard let url = URL(string: urlString) else { return }
        
        // Create data task for downloading image
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Capture strong reference to self if it still exists
            guard let strongSelf = self else { return }
            
            // Return if any error occurred
            if error != nil { return }
            
            // Verify successful HTTP response (status code 200)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            
            // Ensure data exists
            guard let data = data else { return }
            
            // Attempt to create image from data
            guard let image = UIImage(data: data) else { return }
            
            // Store downloaded image in cache
            strongSelf.cache.setObject(image, forKey: cacheKey)
            
            // Update image on main thread
            DispatchQueue.main.async {
                strongSelf.image = image
            }
        }
        
        // Start the download task
        task.resume()
    }
}
