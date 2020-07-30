//
//  UISegmentedControlExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    func getCurrentPosition() -> PaymentStatusType {
        switch self.selectedSegmentIndex
        {
        case 0:
            return .Pending
        case 1:
            return .Received
        case 2:
            return .All
        default:
            Log.exception(message: "Index is out of range for SegmentedControl")
            return .All
        }
    }
}
