//
//  FloatExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit


//MARK: - Float extension

extension Float {
    func ToString(decimals: Int) -> String {
        return String(format: "%.0\(decimals)f", self)
    }
}



extension Float {
    /**
     Creates postfix for showing thousands, millions, etc. as "k", "m", etc
     */
    func pendingNumberRepresentation() -> String {
        
        if self >= 1_000_000_000 {
            let newNumber = (self/1_000_000_000).ToString(decimals: 2)
            return "\(newNumber)b"
        }
        
        if self >= 1_000_000 {
            let newNumber = (self/1_000_000).ToString(decimals: 2)
            return "\(newNumber)m"
        }
        
        if self >= 1000 {
            let newNumber = (self/1000).ToString(decimals: 2)
            return "\(newNumber)k"
        }
        
        return self.ToString(decimals: 2)
    }
}
