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
