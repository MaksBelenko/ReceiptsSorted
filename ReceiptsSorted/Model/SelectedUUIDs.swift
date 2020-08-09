//
//  SelectedUUIDs.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

/// This class was created to optimise the performance of
/// of selecting uids
struct SelectedUIDs {
    /// UIDs of the selected pending payments
    var pendingUIDs: [UUID] = []
    /// UIDs of the selected claimed payments
    var claimedUIDs: [UUID] = []
    
    /// Gets count of all selected UIDs
    var count: Int {
        get { return pendingUIDs.count + claimedUIDs.count}
    }
    
    
    /// Checks weather uid is either in pending or claimed selected UIDs
    func contains(_ uid: UUID) -> Bool {
        if pendingUIDs.contains(uid) || claimedUIDs.contains(uid) {
            return true
        }
        return false
    }
    
    /// Gets all selected UIDs
    func getAll() -> [UUID] {
        var uids = pendingUIDs
        uids.append(contentsOf: claimedUIDs)
        return uids
    }
    
    
    /// Adds UID to an appropriate array
    mutating func append(_ uid: UUID, for paymentReceived: Bool) {
        if paymentReceived {
            claimedUIDs.append(uid)
        } else {
            pendingUIDs.append(uid)
        }
    }
    
    /// Removes UID from an appropriate array
    mutating func remove(_ uid: UUID) {
        guard let pendingIndex = pendingUIDs.firstIndex(of: uid) else {
            let claimedIndex = claimedUIDs.firstIndex(of: uid)!
            claimedUIDs.remove(at: claimedIndex)
            return
        }
        pendingUIDs.remove(at: pendingIndex)
    }
    
    
    /// Removes all selected UIDs
    mutating func removeAll() {
        pendingUIDs.removeAll()
        claimedUIDs.removeAll()
    }
}
