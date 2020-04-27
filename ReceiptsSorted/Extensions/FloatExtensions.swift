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
