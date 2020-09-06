//
//  WorkReceiptsTests.swift
//  WorkReceiptsTests
//
//  Created by Maksim on 14/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import XCTest
@testable import WorkReceipts

class DatabaseAsyncTests: XCTestCase {

    // MARK: Properties
    var coreDataStack: CoreDataStack!
    var database: DatabaseAsync!
    
    
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        continueAfterFailure = false
    
        coreDataStack = DevNullCoreDataStack()
        database = DatabaseAsync(coreDataStack: coreDataStack)
    }
    
    override func tearDownWithError() throws {
        coreDataStack = nil
        database = nil
    }
    
    
    
    // MARK: - Tests
    
    
    func test_removeAllReceiptsOlderThanDate() {
        
        /* ----- Adding receipts with older date ----- */
        let sevenMonthOldDate = Calendar.current.date(byAdding: .month, value: -5, to: Date())!
        let eightMonthOldDate = Calendar.current.date(byAdding: .month, value: -8, to: Date())!
        
        let info1 = PaymentInformation(amountPaid: 12, place: "TestPlace", date: sevenMonthOldDate, receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        let info2 = PaymentInformation(amountPaid: 12, place: "TestPlace", date: eightMonthOldDate, receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        
        let _ = addSinglePayment(with: info1)
        let _ = addSinglePayment(with: info2)
        
        
        /* ----- Removing receipts older than a date ----- */
        let sixMonthOldDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let removeExp = self.expectation(description: "RemoveExpectation")
        database.removeAllReceipts(olderThan: sixMonthOldDate, paymentStatus: .Pending) {
            removeExp.fulfill()
        }
        wait(for: [removeExp], timeout: 3)
        
        
        /* ----- Check the count (should be 0 as all should be removed) ----- */
        let expectation = self.expectation(description: "CheckRemoved")
        var count: Int?
        database.countPayments(for: .All) { returnedCount in
            count = returnedCount
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssert(count == 1, "Count should be 1")
    }
    
    
    
    
    func test_fetchSinglePaymentAsync() {
        let info = PaymentInformation(amountPaid: 12, place: "TestPlace", date: Date(), receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        let uid = addSinglePayment(with: info)
        
        let expectation = self.expectation(description: "FetchPayment")
        var payment: Payment?
        
        XCTAssertNotNil(uid)
        
        database.fetchSinglePaymentAsync(with: uid!) { fetchedPayment in
            payment = fetchedPayment
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 4)
        
        XCTAssertNotNil(payment, "The payment should've been retrieved")
        XCTAssert(info.amountPaid == payment!.amountPaid)
        XCTAssert(info.place == payment!.place)
        XCTAssert(info.date == payment!.date)
        XCTAssert(info.currencySymbol == payment!.currencySymbol)
        XCTAssert(info.currencyName == payment!.currencyName)
    }
    
    
    func test_GetAllUids() throws {
        let numberOfAddedReceipts = 10
        addReceiptSamples(number: numberOfAddedReceipts)
        
        let expectation = self.expectation(description: "asd")
        var fetchedUids: [UUID]?
        
        database.getAllUids(for: .All) { uids in
            fetchedUids = uids
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
        // Check that the correct number of UIDs is created
        XCTAssert(fetchedUids?.count == numberOfAddedReceipts, "Number of UUIDs should be equal to number of added receipts")
        
        // Check that all UUIDs are unique
        let unique = Array(Set(arrayLiteral: fetchedUids))
        XCTAssert(unique[0]!.count == fetchedUids?.count, "Each UUID should be unique")
    }
    
    
    
    func test_GetUidCount() throws {
        let numberOfAddedReceipts = 10
        let addedUids = addReceiptSamples(number: numberOfAddedReceipts)
        
        let firstUid = addedUids.first!
        
        let expectation = self.expectation(description: "TestUId")
        var count: Int?
        
        // Test fetch count with a single UID which only should return a count of 1
        database.getUidCount(for: [firstUid], with: .All) { fetchedCount in
            count = fetchedCount
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 4)
        
        XCTAssert(count == 1, "Fetched count from database should be equal to 1")
    }
    
    
    
    
    func test_FetchTotalAmount() throws {
        let expectation = self.expectation(description: "CountCurrencies")
        let paymentInfo = PaymentInformation(amountPaid: 12, place: "TestPlace", date: Date(), receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        var payments: [Payment]?
        
        database.addAsync(paymentInfo: paymentInfo) { returnedInfo in
            self.database.fetchDataAsync(by: .NewestDateAdded, and: .All) { retPayments in
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

    
    
    
    
    
    // MARK: - Helper methods
    
    @discardableResult
    private func addReceiptSamples(number: Int) -> [UUID] {
        let expectation = self.expectation(description: "addReceipts")
        
        let paymentInfo = PaymentInformation(amountPaid: 12, place: "TestPlace", date: Date(), receiptImage: #imageLiteral(resourceName: "Receipt-Test"), currencySymbol: "£", currencyName: "British Pound Sterling")
        
        var count = 0
        var uids: [UUID] = []
        
        for _ in 1...number {
            database.addAsync(paymentInfo: paymentInfo) { returnedInfo in
                count += 1
                uids.append(returnedInfo.uid)
                if count == number {
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        
        return uids
    }
    
    
    @discardableResult
    private func addSinglePayment(with info: PaymentInformation) -> UUID? {
        let expectation = self.expectation(description: UUID().description)
        
        var uid: UUID?
        database.addAsync(paymentInfo: info) { returnedInfo in
            uid = returnedInfo.uid
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 4, handler: nil)
        
        return uid
    }
}
