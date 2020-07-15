//
//  PaymentsSorting.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation


enum SortType {
    case OldestDateAdded, NewestDateAdded, Place, None
}

enum PaymentStatusType {
    case Pending, Received, All
}




// MARK: - SortBy Extension
extension SortType {
    /**
    Returns SortDescriptor for payments for DB
    */
    func getSortDescriptor() -> NSSortDescriptor? {
        var sortDescriptor: NSSortDescriptor? = nil
        
        switch self
        {
        case .Place:
            let compareSelector = #selector(NSString.localizedStandardCompare(_:))
            sortDescriptor = NSSortDescriptor(key: #keyPath(Payment.place), ascending: true, selector: compareSelector)
        case .NewestDateAdded:
            sortDescriptor = NSSortDescriptor(key: #keyPath(Payment.date), ascending: false)
        case .OldestDateAdded:
            sortDescriptor = NSSortDescriptor(key: #keyPath(Payment.date), ascending: true)
        case .None:
            break
        }
        
        return sortDescriptor
    }
}


// MARK: - PaymentStatusType extension
extension PaymentStatusType {
    /**
     Returns predicate for payments for DB
     */
    func getPredicate() -> NSPredicate? {
        var predicate: NSPredicate? = nil
        
        switch self
        {
        case .Pending:
            predicate = NSPredicate(format: "%K == %@", #keyPath(Payment.paymentReceived), NSNumber(value: false))
        case .Received:
            predicate = NSPredicate(format: "%K == %@", #keyPath(Payment.paymentReceived), NSNumber(value: true))
        case .All:
            break
        }
        
        return predicate
    }
}
