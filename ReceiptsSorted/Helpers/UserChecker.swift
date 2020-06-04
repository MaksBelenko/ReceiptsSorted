//
//  NewUserChecker.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class UserChecker {
    
    private let keyName = "isOldUser"
    
    func isOldUser() -> Bool {
        return UserDefaults.standard.bool(forKey: keyName)
    }
    
    func setIsOldUser() {
        UserDefaults.standard.set(true, forKey: keyName)
    }
    
    func testSetIsNewUser() {
        UserDefaults.standard.set(false, forKey: keyName)
    }
}
