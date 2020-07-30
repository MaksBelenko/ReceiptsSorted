//
//  SelectedUUIDs.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

struct SelectedUIDs {
    var pendingUIDs: [UUID] = []
    var claimedUIDs: [UUID] = []
    
    var count: Int {
        get { return pendingUIDs.count + claimedUIDs.count}
    }
    
    
    func contains(_ uid: UUID) -> Bool {
        if pendingUIDs.contains(uid) || claimedUIDs.contains(uid) {
            return true
        }
        return false
    }
    
    func getAll() -> [UUID] {
        var uids = pendingUIDs
        uids.append(contentsOf: claimedUIDs)
        return uids
    }
    
    
    
    mutating func append(_ uid: UUID, for paymentReceived: Bool) {
        if paymentReceived {
            claimedUIDs.append(uid)
        } else {
            pendingUIDs.append(uid)
        }
    }
    
    
    mutating func remove(_ uid: UUID) {
        guard let pendingIndex = pendingUIDs.firstIndex(of: uid) else {
            let claimedIndex = claimedUIDs.firstIndex(of: uid)!
            claimedUIDs.remove(at: claimedIndex)
            return
        }
        pendingUIDs.remove(at: pendingIndex)
    }
    
    mutating func removeAll() {
        pendingUIDs.removeAll()
        claimedUIDs.removeAll()
    }
}
