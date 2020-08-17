//
//  WorkReceiptsTests.swift
//  WorkReceiptsTests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest
@testable import WorkReceipts

class WorkReceiptsTests: XCTestCase {

    // MARK: Properties
    var coreDataStack: CoreDataStack!
    
    
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        continueAfterFailure = false
    
        coreDataStack = DevNullCoreDataStack()
    }
    
    override func tearDownWithError() throws {
        coreDataStack = nil
    }
    
    
    
    // MARK: - Tests
    
    func testExample() throws {
        let database = DatabaseAsync(coreDataStack: coreDataStack)
        
        let expectation = self.expectation(description: "CountCurrencies")
        let paymentInfo = PaymentInformation(amountPaid: 12, place: "TestPlace", date: Date(), receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        var payments: [Payment]?
        
        database.addAsync(paymentInfo: paymentInfo) { returnedInfo in
            database.fetchDataAsync(by: .NewestDateAdded, and: .All) { retPayments in
                payments = retPayments
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        
        XCTAssert(payments?.count == 1)
        
        
        let expectation2 = self.expectation(description: "asd")
        var totalAmount: Float?
        
        database.getTotalAmountAsync(of: .Pending, for: "British Pound Sterling") { total in
            totalAmount = total
            expectation2.fulfill()
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        
        XCTAssert(totalAmount == 12)
    }

}
