//
//  NewUserChecker.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class UserChecker {
    
    private let oldUserKey = "isOldUser"
    private let swipeDemoKey = "swipeDemoShown"
    
    // MARK: - Main Onboarding
    /**
     Checks weather the application is first time openned.
     - Returns: Boolean showing it is a new user or the app was used before.
     */
    func isIntroOnboardingShown() -> Bool {
        return UserDefaults.standard.bool(forKey: oldUserKey)
    }
    
    /**
     Sets user key to "true" as a default meaning that onboarding already happened.
     
     Keep in mind that this does not affect Swipe Demo that will
     be shown after first receipt is added.
     */
    func setIntroOnboardingAsShown(value: Bool = true) {
        UserDefaults.standard.set(value, forKey: oldUserKey)
    }
    
    
    // MARK: - Swipe Demo
    /**
     Shows weather Swipe Demo was already shown
     
     Swipe demo should be shown after first receipt added
     and never after.
     - Returns: Boolean showing if swipe demo was already presented before.
     */
    func wasSwipeDemoShown() -> Bool {
        return UserDefaults.standard.bool(forKey: swipeDemoKey)
    }
    
    
    /**
     Sets swipe demo key to "true" meaning it was already shown
     */
    func setSwipeDemoAsShown() {
        UserDefaults.standard.set(true, forKey: swipeDemoKey)
    }
}
