//
//  PaymentTableSection.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//



/**
 Single section for Card's tableView payments
 */
struct PaymentTableSection {
    
    /// First letter or a month name
    var key : String
    ///Payments that have the same first letter or month
    var payments : [Payment]
}
