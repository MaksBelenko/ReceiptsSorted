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
    func ToString(as format: DateFormatter.Style) -> String {
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
