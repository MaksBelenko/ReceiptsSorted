//
//  DateExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit


//MARK: - Date extension
extension Date {
    func toString(as format: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: self)
    }
}


extension Date {
    func toDateString() -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        return "\(day) \(month.mapToMonth()) \(year)"
    }
}



extension Date {
    func startOfMonth() -> Date? {
        let components: DateComponents = Calendar.current.dateComponents([.year, .month, .hour],
                                                                         from: Calendar.current.startOfDay(for: self))
        return Calendar.current.date(from: components)!
    }

    func endOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.month, .day, .hour],
                                                         from: Calendar.current.startOfDay(for: self))
        components.month = 1
        components.day = -1
        return Calendar.current.date(byAdding: components, to: self.startOfMonth()!)!
    }
}
