//
//  UIView + Ext.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/29/25.
//

import UIKit

extension UIView {
    
    /// Adds multiple subviews to the view
    /// - Parameter views: Variadic parameter accepting multiple UIView instances
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
