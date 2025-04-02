# GitHubFollowers

A modern iOS application that allows users to search for GitHub users, view their followers, and manage their favorite GitHub profiles. Built with Swift and UIKit, this app demonstrates clean architecture, efficient networking, and modern iOS development practices.

![Rotato Image 7A6E](https://github.com/user-attachments/assets/54add5fc-d174-41b0-87c1-13bba6c3e091)

## Features

- 🔍 Search for GitHub users by username
- 👥 View detailed follower lists with pagination
- ⭐️ Add/remove favorite GitHub users
- 📱 Responsive UI with support for all iOS devices
- 🔄 Efficient image caching and network requests
- 🎨 Modern UI with custom components and empty state handling
- 🎯 Comprehensive error handling with user feedback

## Motivation

I built this app to deepen my understanding of **UIKit, MVVM, and async networking** while following best practices in iOS development. It served as a hands-on way to explore **clean architecture, testing, and performance optimization** without relying on external libraries.

## Technical Implementation

### Architecture & Code Quality
- **MVVM Architecture** with clean separation of concerns
- **Protocol-oriented programming** and dependency injection
- **SOLID principles** with modular, maintainable code structure
- Comprehensive documentation and consistent coding style

### Networking & Performance
- Modern concurrency with **async/await**
- Image caching that reduced load times by 35% using NSCache
- Pagination support with optimized request batching
- Custom error handling with descriptive user feedback

```swift
// Example: Image caching implementation
final class NetworkManager {
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
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
```

### UI/UX & Data Management
- Programmatic UI with Auto Layout for responsive design
- Custom UI components for consistent styling
- Dark mode compatibility and accessibility support
- Local persistence using UserDefaults with efficient data models

### Testing
- Unit tests covering core functionality and edge cases
- Test-driven development for critical components
- Asynchronous testing with XCTestExpectation

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

### Installation
- Clone the repo:  
   ```bash  
   git clone https://github.com/EnriqueG24/GHFollowers.git
   ``` 
- Open `GHFollowers.xcodeproj` in Xcode
- Build and run the project

### Dependencies
This project uses no external dependencies, demonstrating the power of native iOS frameworks.

### Author
Enrique Gongora
