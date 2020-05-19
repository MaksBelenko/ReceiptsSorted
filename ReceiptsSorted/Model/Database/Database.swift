//
//  Database.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/01/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import CoreData

class Database {
    
    let paymentsEntityName: String = "Payments"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imageCompression = ImageCompression()
    
    let settings = Settings()
    
    
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
    private func loadPayments(with request: NSFetchRequest<Payments> = Payments.fetchRequest()) -> [Payments] {
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
            return []
        }
    }
    
    
    //MARK: - Fetch methods
    
    /**
     Fetch all payments from database which contain the passed place name
     - Parameter name: Place's name that is used to filter and fetch data
                       from database
     */
    func fetchData(forName name: String, by sort: SortBy, and paymentStatus: PaymentStatusSort) -> [Payments]{
        let request: NSFetchRequest<Payments> = Payments.fetchRequest()
        
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
            let sd = NSSortDescriptor(key: #keyPath(Payments.place), ascending: true, selector: compareSelector)
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
    func fetchSortedData(by sort: SortBy, and paymentStatus: PaymentStatusSort) -> [Payments] {
        let request: NSFetchRequest<Payments> = Payments.fetchRequest()
        
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
    func fetchData(containsUIDs uidArray: [UUID]) -> [Payments] {
        let request: NSFetchRequest<Payments> = Payments.fetchRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(Payments.uid), uidArray)
        
        return loadPayments(with: request)
    }
    
    
    
    
    //MARK: - Add & Update Payment methods
    
    /**
     Adds a payments to database and returns a tuple of the totals before and after the payment
     - Parameter payment: Tuple that is used to create a new entry in the database
     */
    func add (payment: (amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) -> PaymentTotalInfo{
        let totalBefore = getTotalAmount(of: .Pending)
        
        let newPayment = Payments(context: context)
        newPayment.uid = UUID()
        newPayment.amountPaid = payment.amountPaid
        newPayment.place = payment.place
        newPayment.date = payment.date
//        newPayment.receiptPhoto?.imageData = imageCompression.compressImage(for: payment.receiptImage)
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
     - Parameter dataTuple: Tuple used to update the payment information
     */
    func update(payment: Payments, with dataTuple: (amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) -> PaymentTotalInfo {
        let totalBefore = getTotalAmount(of: .Pending)
        
        payment.receiptPhoto?.imageData = dataTuple.receiptImage.jpegData(compressionQuality: settings.compression)
        payment.amountPaid = dataTuple.amountPaid
        payment.place = dataTuple.place
        payment.date = dataTuple.date
        
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
    func updateDetail(for payment: Payments, detailType: PaymentDetail, with newDetail: Any) {
        switch detailType {
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
    func getTotalAmount(of sortMethod: PaymentStatusSort) -> Float {
        let dictSumName = "sumAmount"
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: paymentsEntityName)
        fetchRequest.resultType = .dictionaryResultType
        let sumExpressionDescr = NSExpressionDescription()
        sumExpressionDescr.name = dictSumName
        
        let amountSumExp = NSExpression(forKeyPath: #keyPath(Payments.amountPaid))
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
