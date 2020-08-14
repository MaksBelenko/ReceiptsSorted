//
//  XCUIApplication+Ext.swift
//  WorkReceiptsUITests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

// MARK: - XCUIApplication Extension
extension XCUIApplication {
    
    /**
     Sets userdefaults for Onboarding
     */
    func setSeenOnboarding(to seenOnboarding: Bool = true) {
        launchArguments += ["-isOldUser", seenOnboarding ? "true" : "false"]
        launchArguments += ["-swipeDemoShown", seenOnboarding ? "true" : "false"]
    }
}
