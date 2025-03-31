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
    
    /// Pins the edges of the view to the edges of its superview.
    ///
    /// This helper method quickly anchors a view to all edges (top, leading, trailing, bottom)
    /// of its superview using Auto Layout constraints. It automatically sets
    /// `translatesAutoresizingMaskIntoConstraints` to `false` for you.
    ///
    /// - Parameter superview: The superview to which the edges will be pinned.
    /// - Important: The view must already be added as a subview of the specified superview
    ///   before calling this method, otherwise it will result in a runtime error.
    ///
    /// # Example
    /// ```
    /// let childView = UIView()
    /// parentView.addSubview(childView)
    /// childView.pinToEdges(of: parentView)
    /// ```
    ///
    /// - Note: This method uses zero padding between the views.
    func pinToEdges(of superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
}
