//
//  Settings.swift
//  ReceiptsSorted
//
//  Created by Maksim on 23/02/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class Settings {
    
    static let shared = Settings()
    
    ///0 is maximum compression, 1 is no compression
    var compression : CGFloat = 0.0
    var currencySymbol: String = "£"
    var imageCompression: ImageCompressionEnum = .Best
}
