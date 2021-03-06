//
//  WorkReceiptsUITests.swift
//  WorkReceiptsUITests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

class PaymentVcUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.setSeenOnboarding(to: true)
        app.resetDatabase()
        app.launch()
        
        openPaymentVcWithPhotoLibraryImage()
//        sleep(3) // Sleeps is needed to be able to register taps or double tap
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    // MARK: - Tests
    
    func testAddReceipt() {
        
        // Fill Place TextField
        let placeTextField = app.textFields["placeTextField"]
        placeTextField.tap()
        placeTextField.tap()
        placeTextField.typeText("TestPlace")
        
        // Fill Amount TextField
        let amountField = app.textFields.containing(.staticText, identifier:"£  ").element
        amountField.tap()
        amountField.typeText("100")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        // Press add button to add receipts
        let addButton = app.buttons["Add"]
        addButton.tap()
        
        let newCell = app.tables.cells.staticTexts["£100.00"]
        XCTAssert(newCell.exists, "The cell should have been added to the Card's tableView")
        
    }
    
//    func test_PaymentVC_SaveToPhotos() {
//        
//        app.navigationBars["Payment Details"].buttons["save to photos"].tap()
//        app.sheets["Do you want to save the receipt image to your photos?"].scrollViews.otherElements.buttons["Yes, save"].tap()
//        app.alerts["Receipt image saved"].scrollViews.otherElements.buttons["OK"]/*@START_MENU_TOKEN@*/.tap()/*[[".tap()",".press(forDuration: 1.0);"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
//    }
//    
    
    
    /**
     Tests date picker for PaymentVC
     */
    func testCheckDatePicker() {
        
        
        let datetextfieldTextField = app.textFields["dateTextField"]
        datetextfieldTextField.tap()
        datetextfieldTextField.tap()
        
        var dateTextBefore = datetextfieldTextField.value as! String
        
        // Get the left wheel of DatePicker and swipe
        let datePicker = app.datePickers["PaymentVcDatePicker"]
        let wheel = datePicker.pickerWheels.element(boundBy: 0)
        wheel.swipeDown()

        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons["Done"].tap()
        var dateTextNew = datetextfieldTextField.value as! String
        
        
        XCTAssert(dateTextBefore != dateTextNew, "Date shouldn't much after datePicker month scrolling")
        
        
        /* ------- Test Cancel button in toolbar ------- */
        dateTextBefore = dateTextNew
        
        datetextfieldTextField.tap()
        toolbar.buttons["Cancel"].tap()
        
        dateTextNew =  datetextfieldTextField.value as! String
        
        XCTAssert(dateTextBefore == dateTextNew, "Date should be equal after datePicker was cancelled")
        
    }
    
    /**
     Tests Payment View Controller "Fill all data" alert
     */
    func testFillAlert() throws {
        
        /* --------- Fill all data alert test (All empty) --------- */
        let addButton = app.buttons["Add"]
        // In order for for button to be tapped in PaymentVC it should
        // be either double tap or a sleep(1) before thethe tap (XCTest bug)
        //        addButton.tap()
        addButton.tap()
        addButton.tap()
        
        fillDataAlertCheckAndClose()
        
        
        /* ------- Fill all data alert test (Amount empty) ------- */
        let placeTextField = app.textFields["placeTextField"]
        placeTextField.tap()
        
        placeTextField.typeText("asdasd")
        // Press Return on keyboard
        app.buttons["Return"].tap()
        
        addButton.tap()
        fillDataAlertCheckAndClose()
        
        /* ------- Fill all data alert test (Place empty) ------- */
        placeTextField.clearAndEnterText(text: "") // Clean textfield
        app.buttons["Return"].tap()
        
        
        let amountField = app.textFields.containing(.staticText, identifier:"£  ").element
        amountField.tap()
        
        amountField.typeText("12")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        addButton.tap()
        fillDataAlertCheckAndClose()
    }
    
    
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
    
    
    // MARK: - Helper methods
    
    /**
     Get to PaymentVC using first photo in Photo Library
     */
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
    
    
    /**
     Checks that alert appeared and closes it by pressing "OK"
     */
    func fillDataAlertCheckAndClose() {
        let fillAlert = app.alerts["Information missing"]
        XCTAssert(fillAlert.exists == true, "Fill alert should appear if the fields not filled")
        // Tap OK on the Alert asking to fill the data
        fillAlert.scrollViews.otherElements.buttons["OK"].tap()
    }
    
}

