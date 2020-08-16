//
//  PDFShareUITests.swift
//  WorkReceiptsUITests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest

class ShareUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.setSeenOnboarding(to: true) // set to false to show onboarding
        app.resetDatabase()
        app.launch()
        
        sleep(1)
    }
    
    
    override func tearDownWithError() throws {
        
    }
    
    
    // MARK: - Tests
    /*
     Test PDF Sharing
     */
    func testSharePDF() throws {
        openPaymentVcWithPhotoLibraryImage()
        
        let placeName = "TestReceipt"
        addReceipt(withName: placeName)
        
        /* ----------- Select and try to share -----------*/
        app.buttons["envelope"].tap()
        app.tables.staticTexts["\(placeName)"].tap()
        app.buttons["emailNextButton"].tap()
        app.sheets["Send receipts as:"].scrollViews.otherElements.buttons["PDF (Table & photos)"].tap()
        
        // press share button
        let shareButton = app.navigationBars["PDF Preview"].buttons["send"]
        shareButton.tap()
        shareButton.tap()
        
        // Close UIActivityViewController to test if it appeared
        app.otherElements["ActivityListView"].navigationBars["UIActivityContentView"].buttons["Close"].tap()
    }
    
    
    /*
     Test Sharing Zip
     */
    func testSharePhotos() throws {
        openPaymentVcWithPhotoLibraryImage()
        
        let placeName = "TestReceipt"
        addReceipt(withName: placeName)
        
        /* ----------- Select and try to share -----------*/
        app.buttons["envelope"].tap()
        app.tables.staticTexts["\(placeName)"].tap()
        app.buttons["emailNextButton"].tap()
        
        
        app.sheets["Send receipts as:"].scrollViews.otherElements.buttons["Photos only"].tap()
    
        
        // press share button
        let shareButton = app.navigationBars["Images Viewer"].buttons["Share"]
        shareButton.tap()
        shareButton.tap()
        
        /* ---------------- Test Zip ---------------- */
        app.sheets["How do you want to send images?"].scrollViews.otherElements.buttons["Zip Archive"].tap()
        // Close UIActivityViewController to test if it appeared
        app.otherElements["ActivityListView"].navigationBars["UIActivityContentView"].buttons["Close"].tap()
        
        
        /* ---------------- Test Photos ---------------- */
        shareButton.tap()
        app.sheets["How do you want to send images?"].scrollViews.otherElements.buttons["Just images"].tap()
        // Close UIActivityViewController to test if it appeared
        app.otherElements["ActivityListView"].navigationBars["UIActivityContentView"].buttons["Close"].tap()
    }

    
    
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
    }
    
    
    func addReceipt(withName name: String) {
        // Fill Place TextField
        let placeTextField = app.textFields["placeTextField"]
        placeTextField.tap()
        placeTextField.tap()
        placeTextField.typeText(name)
        
        // Fill Amount TextField
        let amountField = app.textFields.containing(.staticText, identifier:"£  ").element
        amountField.tap()
        amountField.typeText("100")
        app.toolbars["Toolbar"].buttons["Done"].tap()
        
        // Press add button to add receipts
        let addButton = app.buttons["Add"]
        addButton.tap()
        
        sleep(1)
        let newCell = app.tables.cells.staticTexts["£100.00"]
        XCTAssert(newCell.exists, "The cell should have been added to the Card's tableView")
    }
    
}
