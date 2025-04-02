# GHFollowers

A modern iOS application that allows users to search for GitHub users, view their followers, and manage their favorite GitHub profiles. Built with Swift and UIKit, this app demonstrates clean architecture, efficient networking, and modern iOS development practices.

## Features

- 🔍 Search for GitHub users by username
- 👥 View detailed follower lists with pagination
- ⭐️ Add/remove favorite GitHub users
- 📱 Responsive UI with support for all iOS devices
- 🔄 Efficient image caching and network requests
- 🎨 Modern UI with custom components
- 📱 Empty state handling
- 🔍 Real-time search filtering
- 🎯 Error handling and user feedback
- ✅ Comprehensive unit testing

## Technical Highlights

### Architecture
- MVVM architecture with clean separation of concerns
- Protocol-oriented programming
- Dependency injection
- Singleton pattern for network and persistence managers
- Clear separation of business logic from UI components
- Modular and maintainable code structure

### Testing
- Comprehensive unit tests for core functionality
- Test-driven development approach for critical components
- Asynchronous testing with XCTestExpectation
- Proper test isolation and cleanup
- Testing of both success and failure scenarios
- Coverage of edge cases and error conditions

### Networking
- Async/await for modern concurrency
- Efficient image caching using NSCache
- Error handling with custom error types
- Pagination support for follower lists
- Network request optimization
- Proper error propagation and handling

### UI/UX
- Custom UI components (buttons, labels, text fields)
- Programmatic UI with Auto Layout
- Empty state handling
- Loading states and error feedback
- Modern iOS patterns and best practices
- Accessibility support
- Dark mode compatibility

### Data Management
- Local persistence using UserDefaults
- Efficient data caching
- Memory management
- State management
- Data validation and sanitization
- Proper data model design

### Code Quality
- SwiftLint integration for code style consistency
- Comprehensive documentation
- Clear naming conventions
- SOLID principles adherence
- Clean code practices
- Performance optimization

## Screenshots
![Rotato Image 7A6E](https://github.com/user-attachments/assets/54add5fc-d174-41b0-87c1-13bba6c3e091)

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `GHFollowers.xcodeproj` in Xcode
3. Build and run the project

## Dependencies

This project uses no external dependencies, demonstrating the power of native iOS frameworks.

## Author

Enrique Gongora
