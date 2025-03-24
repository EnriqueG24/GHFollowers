//
//  UIHelper.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/24/25.
//

import UIKit

struct UIHelper {
    
    /// Creates a `UICollectionViewFlowLayout` configured for a three-column grid layout.
    ///
    /// This layout includes consistent padding around the section and spacing between items.
    /// The item width is dynamically calculated based on the provided view’s width, allowing
    /// for three equally spaced columns.
    ///
    /// - Parameter view: The `UIView` whose width is used to calculate the layout dimensions.
    /// - Returns: A `UICollectionViewFlowLayout` configured with section insets and item size suitable for a three-column layout.
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
}
