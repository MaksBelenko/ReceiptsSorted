//
//  Database.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/01/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import CoreData

protocol PaymentsFetchedDelegate: AnyObject {
    func onPaymentsFetched(newPayments: [Payment])
}


class DatabaseAdapter {
    
    weak var delegate: PaymentsFetchedDelegate?
    
    private let paymentsEntityName: String = "Payment"
    private lazy var context = CoreDataStack(modelName: "PaymentsData").managedContext
    private let imageCompression = ImageCompression()
    private let settings = Settings.shared
    
    
    
    //MARK: - Basic methods
    
    /**
     Attempts to commit unsaved changes to registered objects to the context’s parent store.
     */
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error found when saving context: \(error)")
        }
    }
    
    
    /**
     Deletes an item in the database
     - Parameter item: Item to delete from database
     */
    func delete(item: NSManagedObject) {
        context.delete(item)
        saveContext()
    }
        
    
    /**
     Get all payments from database
     - Parameter request: NSFetchRequest that is used to fetch data from database
     */
    private func loadPayments(with request: NSFetchRequest<Payment> = Payment.fetchRequest()) -> [Payment] {
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
            return []
        }
         
//        loadPaymentsAsync(with: request)
//        return []
    }
    
    
    
    
    
    func loadPaymentsAsync(with request: NSFetchRequest<Payment> = Payment.fetchRequest(), completion: @escaping ([Payment]) -> ()) {
        let asyncFetchRequest = NSAsynchronousFetchRequest<Payment>( fetchRequest: request) { [unowned self] (result: NSAsynchronousFetchResult) in
            guard let fetchedPayments = result.finalResult else { return }
            self.delegate?.onPaymentsFetched(newPayments: fetchedPayments)
            completion(fetchedPayments)
        }
        
        do {
            try context.execute(asyncFetchRequest)
        } catch {
            Log.exception(message: "Error executing asynchronous fetch: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Fetch methods
    
    /**
     Fetch all payments from database which contain the passed place name
     - Parameter name: Place's name that is used to filter and fetch data
                       from database
     */
    func fetchData(forName name: String, by sort: SortType, and paymentStatus: PaymentStatusType) -> [Payment]{
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        if (name != "") {
            //[cd] is to make it non-casesensitive and non-diacritic
            let predicateSearchName = NSPredicate(format: "place CONTAINS[cd] %@", name)

            // Set predicate for fetch request
            let predicatePaymentReceived = paymentStatus.getPredicate()

            
            if let secondPredicate = predicatePaymentReceived {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateSearchName, secondPredicate])
            } else {
                request.predicate = predicateSearchName
            }
            
            
            let compareSelector = #selector(NSString.localizedStandardCompare(_:))
            let sd = NSSortDescriptor(key: #keyPath(Payment.place), ascending: true, selector: compareSelector)
            request.sortDescriptors = [sd]
            
            return loadPayments(with: request)
            
        } else {
            return fetchSortedData(by: sort, and: paymentStatus)
        }
        
    }
    
    
    /**
     Fetch sorted data from database
     - Parameter type: by what parameter should the data be sorted
     */
    func fetchSortedData(by sort: SortType, and paymentStatus: PaymentStatusType) -> [Payment] {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        // Set predicate for fetch request
        if let predicate = paymentStatus.getPredicate() {
            request.predicate = predicate
        }
        
        // Set sortDescriptor for fetch request
        if let sortDescriptor = sort.getSortDescriptor() {
            request.sortDescriptors = [sortDescriptor]
        }
        
        return loadPayments(with: request)
    }
    
    
    /**
     Fetches data from the array of UIDs of the payments
     - Parameter uidArray: Array of UIDs
     */
    func fetchData(containsUIDs uidArray: [UUID]) -> [Payment] {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(Payment.uid), uidArray)
        
        return loadPayments(with: request)
    }
    
    
    
    
    //MARK: - Add & Update Payment methods
    
    /**
     Adds a payments to database and returns a tuple of the totals before and after the payment
     - Parameter payment: Tuple that is used to create a new entry in the database
     */
    func add (payment: PaymentInformation) -> PaymentTotalInfo {
        let totalBefore = getTotalAmount(of: .Pending)
        
        let newPayment = Payment(context: context)
        newPayment.uid = UUID()
        newPayment.amountPaid = payment.amountPaid
        newPayment.place = payment.place
        newPayment.date = payment.date
        newPayment.paymentReceived = false

        let receiptPhoto = ReceiptPhoto(context: context)
        receiptPhoto.imageData = imageCompression.compressImage(for: payment.receiptImage)
        newPayment.receiptPhoto = receiptPhoto
        
        saveContext()
       
        let totalAfter = getTotalAmount(of: .Pending)
        return PaymentTotalInfo(payment: newPayment, totalBefore: totalBefore, totalAfter: totalAfter)
    }
    
    
    /**
     Updates a payments with the information passed in tuple
     - Parameter payment: Payment from the database to be updated
     - Parameter paymentInfo: Tuple used to update the payment information
     */
    func update(payment: Payment, with paymentInfo: PaymentInformation) -> PaymentTotalInfo {
        let totalBefore = getTotalAmount(of: .Pending)
        
        payment.receiptPhoto?.imageData = paymentInfo.receiptImage.jpegData(compressionQuality: settings.compression)
        payment.amountPaid = paymentInfo.amountPaid
        payment.place = paymentInfo.place
        payment.date = paymentInfo.date
        
        saveContext()
        
        let totalAfter = getTotalAmount(of: .Pending)
        return PaymentTotalInfo(payment: payment, totalBefore: totalBefore, totalAfter: totalAfter)
    }
    
    
    /**
     Update individual attribute of payment in the database
     - Parameter payment: Entry to update
     - Parameter detailType: Enum of the attributes
     - Parameter newDetail: Value that the attribute of the entry should be updated with.
                            AmountPaid -> Float; Place -> String; ReceiptPhoto -> Data;
                            PaymentReceived -> Bool
     */
    func updateField(for payment: Payment, fieldType: PaymentField, with newDetail: Any) {
        switch fieldType {
        case .AmountPaid:
            payment.amountPaid = newDetail as! Float
        case .Place:
            payment.place = newDetail as? String
        case .Image:
            payment.receiptPhoto?.imageData = newDetail as? Data
        case .PaymentReceived:
            payment.paymentReceived = newDetail as! Bool
        }
        
        saveContext()
    }
    
    
    
    
    // MARK: - Fault the entity
    
    /**
     Faults the object in order to remoove it from memory
     */
    func refault(object: NSManagedObject?) {
        guard let object = object else {
            Log.exception(message: "Refaulting object is nil")
            return
        }
        
        context.refresh(object, mergeChanges: true)
    }
    
    
    
    
    // MARK: - Get Total
    
    /**
     Gets total amount of payments
     - Parameter sortMethod: Allows to get a total either for all, pending or received payments
     */
    func getTotalAmount(of sortMethod: PaymentStatusType) -> Float {
        let dictSumName = "sumAmount"
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: paymentsEntityName)
        fetchRequest.resultType = .dictionaryResultType
        let sumExpressionDescr = NSExpressionDescription()
        sumExpressionDescr.name = dictSumName
        
        let amountSumExp = NSExpression(forKeyPath: #keyPath(Payment.amountPaid))
        sumExpressionDescr.expression = NSExpression(forFunction: "sum:", arguments: [amountSumExp])
        sumExpressionDescr.expressionResultType = .floatAttributeType
        
        //Set properties to fetch
        fetchRequest.propertiesToFetch = [sumExpressionDescr]
        
        // Set predicate for sortMethod
        if let predicate = sortMethod.getPredicate() {
            fetchRequest.predicate = predicate
        }
        
        var totalAmount: Float = -1
        
        do {
            let results = try context.fetch(fetchRequest)
            
            let resultDict = results.first!
            if let value = resultDict[dictSumName] as? NSNumber {
                totalAmount = value.floatValue
            }
        } catch {
            print(error)
        }
        
        return totalAmount
    }
}
