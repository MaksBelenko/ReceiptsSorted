//
//  OnboardingUITests.swift
//  WorkReceiptsUITests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

class OnboardingUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.setSeenOnboarding(to: false) // set to false to show onboarding
        app.launch()
        
        sleep(1)
    }
    
    
    override func tearDownWithError() throws {
        
    }
    
    
    // MARK: - Tests
    /*
     Onboarding walkthough test
     */
    func testOnboardingMain_Walkthrough() throws {
        goToEndOfOnboarding()
        
        app.buttons["Done!"].tap() // close onboarding
        
        // Check that its on a main screen by tapping
        // "Claimed on segmented Control
        app.segmentedControls.buttons["Claimed"].tap()
        
    }
    
    
    /**
     Back button test for onboarding walkthrough
     */
    func testBackButtons() {
        goToEndOfOnboarding()
        
        let backButton = app/*@START_MENU_TOKEN@*/.buttons["OnboardingBackButton"]/*[[".buttons[\"Back\"]",".buttons[\"OnboardingBackButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        backButton.tap()
        backButton.tap()
        backButton.tap()
        backButton.tap()
    }
    
    
    
    func goToEndOfOnboarding() {
        XCTAssert(app.staticTexts["WelcomeText"].exists, "No welcome text found")
        app.buttons["WelcomeOboardingNextButton"].tap()
        
        let nextButton = app.buttons["OnboardingNextButton"]
        let infoText = app.staticTexts["OboardingInfoText"]

        XCTAssert(infoText.exists, "No Info text for Segmented control")
        nextButton.tap()
        
        XCTAssert(infoText.exists, "No addbutton info found")
        nextButton.tap()
        
        XCTAssert(infoText.exists, "No email info found")
        nextButton.tap()
        
        XCTAssert(infoText.exists, "No indicators description info found")
    }
    
    
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
    
}
