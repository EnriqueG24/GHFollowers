//
//  Date+Ext.swift
//  GHFollowers
//
//  Created by Enrique Gongora on 3/27/25.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
