//
//  PersistenceManagerTests.swift
//  GHFollowersTests
//
//  Created by Enrique Gongora on 4/2/25.
//

import XCTest
@testable import GHFollowers

final class PersistenceManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    private let testFollower = Follower(login: "testUser", avatarUrl: "https://example.com/avatar.jpg")
    private let testFollower2 = Follower(login: "testUser2", avatarUrl: "https://example.com/avatar2.jpg")
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: PersistenceManager.Keys.favorites)
    }
    
    override func tearDown() {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: PersistenceManager.Keys.favorites)
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testAddFavorite() {
        // Given
        let expectation = XCTestExpectation(description: "Add favorite completion")
        
        // When
        PersistenceManager.updateWith(favorite: testFollower, actionType: .add) { error in
            // Then
            XCTAssertNil(error)
            
            // Verify the favorite was added
            PersistenceManager.retrieveFavorites { result in
                switch result {
                case .success(let favorites):
                    XCTAssertEqual(favorites.count, 1)
                    XCTAssertEqual(favorites.first?.login, self.testFollower.login)
                case .failure(let error):
                    XCTFail("Failed to retrieve favorites: \(error)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddDuplicateFavorite() {
        // Given
        let expectation = XCTestExpectation(description: "Add duplicate favorite completion")
        
        // When
        // First add
        PersistenceManager.updateWith(favorite: testFollower, actionType: .add) { error in
            XCTAssertNil(error)
            
            // Try to add the same favorite again
            PersistenceManager.updateWith(favorite: self.testFollower, actionType: .add) { error in
                // Then
                XCTAssertEqual(error, .alreadyInFavorites)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveFavorite() {
        // Given
        let expectation = XCTestExpectation(description: "Remove favorite completion")
        
        // When
        // First add a favorite
        PersistenceManager.updateWith(favorite: testFollower, actionType: .add) { error in
            XCTAssertNil(error)
            
            // Then remove it
            PersistenceManager.updateWith(favorite: self.testFollower, actionType: .remove) { error in
                XCTAssertNil(error)
                
                // Verify it was removed
                PersistenceManager.retrieveFavorites { result in
                    switch result {
                    case .success(let favorites):
                        XCTAssertTrue(favorites.isEmpty)
                    case .failure(let error):
                        XCTFail("Failed to retrieve favorites: \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveEmptyFavorites() {
        // Given
        let expectation = XCTestExpectation(description: "Retrieve empty favorites completion")
        
        // When
        PersistenceManager.retrieveFavorites { result in
            // Then
            switch result {
            case .success(let favorites):
                XCTAssertTrue(favorites.isEmpty)
            case .failure(let error):
                XCTFail("Failed to retrieve favorites: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetrieveMultipleFavorites() {
        // Given
        let expectation = XCTestExpectation(description: "Retrieve multiple favorites completion")
        
        // When
        // Add two favorites
        PersistenceManager.updateWith(favorite: testFollower, actionType: .add) { error in
            XCTAssertNil(error)
            
            PersistenceManager.updateWith(favorite: self.testFollower2, actionType: .add) { error in
                XCTAssertNil(error)
                
                // Then retrieve and verify
                PersistenceManager.retrieveFavorites { result in
                    switch result {
                    case .success(let favorites):
                        XCTAssertEqual(favorites.count, 2)
                        XCTAssertTrue(favorites.contains { $0.login == self.testFollower.login })
                        XCTAssertTrue(favorites.contains { $0.login == self.testFollower2.login })
                    case .failure(let error):
                        XCTFail("Failed to retrieve favorites: \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
