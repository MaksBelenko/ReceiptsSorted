//
//  IntExtensins.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit


//MARK: - Int extension

extension Int {
    /**
     Helper method to easily get name of Month from Int
     */
    func mapToMonth() -> String {
        switch self
        {
        case 1:
                return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
            
        default:
            return "Unknown month"
        }
//        return String(format: "%.0\(decimals)f", self)
    }
}
    
    
extension Int {
    func numberAbbreviation() -> String {
        let lastDigit = self % 10
        
        switch lastDigit
        {
        case 1:
            return "\(self)st"
        case 2:
            return "\(self)nd"
        case 3:
            return "\(self)rd"
        default:
            return "\(self)th"
        }
    }
}
