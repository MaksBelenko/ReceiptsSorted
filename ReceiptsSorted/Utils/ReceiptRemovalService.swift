//
//  ReceiptRemovalService.swift
//  ReceiptsSorted
//
//  Created by Maksim on 06/09/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class ReceiptRemovalService {
    
    var database: DatabaseAsync?
    var refreshPayments: ((() -> ())?)
    private let settings = SettingsUserDefaults.shared
    
    
    func removeOldReceiptsIfNeeded() {
        let removeBeforeMonth = settings.getReceiptRemovalPeriod()
        // If remove receipts settings is enabled (not -1)
        // then run command to remove older receipts
        if (removeBeforeMonth > 0) {
            let date = Calendar.current.date(byAdding: .month, value: -removeBeforeMonth, to: Date())!
            database?.removeAllReceipts(olderThan: date, paymentStatus: .Received) { [weak self] in
                self?.refreshPayments?()
            }
        }
    }
}
