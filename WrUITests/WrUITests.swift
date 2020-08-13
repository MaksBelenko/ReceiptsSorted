//
//  WrUITests.swift
//  WrUITests
//
//  Created by Maksim on 13/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

class WrUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    /**
     Tests Payment View Controller Fill all data alert
     */
    func test_PaymentVc_fillAlert() throws {
        openPaymentVcWithPhotoLibraryImage()
        
        
        /* --------- Fill all data alert test (All empty) --------- */
        let addButton = app.buttons["Add"]
        // In order for for button to be tapped in PaymentVC it should
        // be either double tap or a sleep(1) before thethe tap (XCTest bug)
        sleep(1)
//        addButton.tap()
        addButton.tap()
        
        fillDataAlertCheckAndClose()
                  

        /* ------- Fill all data alert test (Amount empty) ------- */
        let placeTextField = app.textFields["placeTextField"]
        placeTextField.tap()

        placeTextField.typeText("asdasd")
        // Press Return on keyboard
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

        addButton.tap()
        fillDataAlertCheckAndClose()

         /* ------- Fill all data alert test (Place empty) ------- */
//        Clean textfield and close
        placeTextField.clearAndEnterText(text: "")
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        let amountField = app.textFields.containing(.staticText, identifier:"£  ").element
        amountField.tap()
        
        amountField.typeText("12")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        addButton.tap()
        fillDataAlertCheckAndClose()
    }
    
    
    
    // MARK: - Helper methods
    func openPaymentVcWithPhotoLibraryImage() {
        let staticText = app.buttons["+"]
        staticText.tap()
        app.buttons["photo.on"].tap()
        
        // Select "Moments" from phot library
        app.cells["Moments"].tap()
        
        // Select first image from photo library
        app.cells.children(matching: .any).element(boundBy: 0).tap()
//        app.cells["Photo, Landscape, March 13, 2011, 12:17 AM"].tap()
    }

    func fillDataAlertCheckAndClose() {
        let fillAlert = app.alerts["Fill all data"]
        XCTAssert(fillAlert.exists == true, "Fill alert should appear if the fields not filled")
        // Tap OK on the Alert asking to fill the data
        fillAlert.scrollViews.otherElements.buttons["OK"].tap()
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


// MARK: - XCUIElement Extension
extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
