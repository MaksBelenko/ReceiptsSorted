//
//  Currency.swift
//  ReceiptsSorted
//
//  Created by Maksim on 12/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

struct Currency: Codable {
    var symbol: String
    var name: String
    var symbol_native: String
    var decimal_digits: Int
    var rounding: Float
    var code: String
    var name_plural: String
}
