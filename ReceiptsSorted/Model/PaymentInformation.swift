//
//  PaymentDetails.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIImage

/// Payment Information
struct PaymentInformation {
    
    /// Amount that was paid
    var amountPaid: Float
    /// Place of purchase as shown on receipt
    var place: String
    /// Date of purchase
    var date: Date
    /// Image of receipt itself
    var receiptImage: UIImage
}
