//
//  DateHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 05/09/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class DateFormatterHelper {
    
    func getDashFomattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
}
