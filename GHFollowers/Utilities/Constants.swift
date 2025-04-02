//
//  Constants.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/26/25.
//

import UIKit

/// Symbolic constants for SF Symbols used throughout the app
/// These provide standardized icon names for UI elements
enum SFSymbols {
    static let location = UIImage(systemName: "mappin.and.ellipse")
    static let repos = UIImage(systemName: "folder")
    static let gists = UIImage(systemName: "text.alignleft")
    static let followers = UIImage(systemName: "heart")
    static let following = UIImage(systemName: "person.2")
}

/// Device screen size information
/// Provides convenient access to screen dimensions for responsive layouts
enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
}

/// Device type detection for adaptive UI decisions
/// Identifies specific device models and their characteristics
enum DeviceType {
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale

    static let isiPhoneSE = idiom == .phone && ScreenSize.maxLength == 667.0 && ScreenSize.minLength == 375.0
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && ScreenSize.minLength == 375.0
    static let isiPhone8Zoomed = idiom == .phone && ScreenSize.maxLength == 667.0 && ScreenSize.minLength == 375.0
    static let isiPhone8PlusStandard = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhoneX = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad = idiom == .pad
    static let isiPadPro = idiom == .pad && ScreenSize.maxLength == 1024.0  

    /// Determines if the device has an iPhone X-style screen aspect ratio
    /// Used for handling notches and safe areas appropriately
    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}

/// Image resources for the app
/// Provides convenient access to image assets
enum Images {
    static let ghLogo = UIImage(resource: .ghLogo)
    static let placeholder = UIImage(resource: .avatarPlaceholder)
    static let emptyStateLogo = UIImage(resource: .emptyStateLogo)
}
