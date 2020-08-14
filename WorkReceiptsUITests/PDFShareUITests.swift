//
//  PDFShareUITests.swift
//  WorkReceiptsUITests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

class PdfShareUITests: XCTestCase {
    
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
    func testSharePDF() throws {
        
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
