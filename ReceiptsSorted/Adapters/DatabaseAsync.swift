//
//  DatabaseAsync.swift
//  ReceiptsSorted
//
//  Created by Maksim on 19/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import CoreData

class DatabaseAsync {
    
    typealias CompletionHandler = ([Payment]) -> ()
    
    private let paymentsEntityName: String = "Payment"
    private let coreDataStack = CoreDataStack(modelName: "PaymentsData")
    private lazy var context = coreDataStack.managedContext
    private lazy var persistentContainer = coreDataStack.persistentContainer
    
    private let imageCompression = ImageCompression()
    private let settings = Settings.shared
    

    
    /// Sort descriptor for places in alphabetical order
    private let placeSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Payment.place), ascending: true, selector: compareSelector)
    }()
    
    
    
    
    // MARK: - Basic Methods
    
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
    
    private func save(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            Log.exception(message: "Error found when saving context: \(error.localizedDescription)")
        }
    }
    
    
    
    func loadPaymentsAsync(with request: NSFetchRequest<Payment> = Payment.fetchRequest(), completion: @escaping CompletionHandler) {
        let asyncFetchRequest = NSAsynchronousFetchRequest<Payment>( fetchRequest: request) { /*[unowned self]*/ (result: NSAsynchronousFetchResult) in
            guard let fetchedPayments = result.finalResult else { return }
            completion(fetchedPayments)
        }
        
        do {
            try context.execute(asyncFetchRequest)
        } catch {
            Log.exception(message: "Error executing asynchronous fetch: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Fetch
    
    /**
     Fetch sorted data from database
     - Parameter type: by what parameter should the data be sorted
     */
    private func fetchSortedDataAsync(by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping CompletionHandler) {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        // Set predicate for fetch request
        request.predicate = paymentStatus.getPredicate()
    
        // Set sortDescriptor for fetch request
        if let sortDescriptor = sort.getSortDescriptor() {
            request.sortDescriptors = [sortDescriptor]
        }
        
        loadPaymentsAsync(with: request, completion: completion)
    }
    
    
    /**
     Fetch all payments from database which contain the passed place name
     - Parameter name: Optional string that is used to search payments in
                       the database (Default value is nil)
     - Parameter sort: General sorting of all payments (eg. sort by .NewestDate)
     - Parameter paymentStatus: Payment status (eg. .Pending)
     - Parameter completion: Completion handler to be executed after the payments
                             are fetched asynchronously
     */
    func fetchDataAsync(forName name: String? = nil, by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping CompletionHandler) {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        if (name == "" || name == nil) {
            fetchSortedDataAsync(by: sort, and: paymentStatus, completion: completion)
            return
        }
        
        //[cd] is to make it non-casesensitive and non-diacritic
        request.predicate = NSPredicate(format: "place CONTAINS[cd] %@", name!)
        request.predicate! += paymentStatus.getPredicate()
        
        request.sortDescriptors = [placeSortDescriptor]
        loadPaymentsAsync(with: request, completion: completion)
    }
    
    
    
    //MARK: - Add & Update Payment methods
    
    /**
     Adds a payments to database and returns a tuple of the totals before and after the payment
     - Parameter paymentInfo: Tuple that is used to create a new entry in the database
     */
    func add (paymentInfo: PaymentInformation, completion: @escaping (PaymentTotalInfo) -> ()) {
        
        getTotalAmountAsync(of: .Pending) { [unowned self] totalBefore in
            
//            let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//            privateMOC.parent = self.context
//
//            privateMOC.perform {
//
//                let newPayment = Payment(context: privateMOC)
//                newPayment.uid = UUID()
//                newPayment.amountPaid = paymentInfo.amountPaid
//                newPayment.place = paymentInfo.place
//                newPayment.date = paymentInfo.date
//                newPayment.paymentReceived = false
//
//                let receiptPhoto = ReceiptPhoto(context: privateMOC)
//                receiptPhoto.imageData = self.imageCompression.compressImage(for: paymentInfo.receiptImage)
//                newPayment.receiptPhoto = receiptPhoto
//
//                do {
//                    try privateMOC.save()
//                    self.context.performAndWait {
//                        do {
//                            try self.context.save()
//                        } catch {
//                            fatalError("Failure to save context: \(error)")
//                        }
//                    }
//
//                    DispatchQueue.main.async {
//                        let totalAfter = totalBefore + paymentInfo.amountPaid
//                        let paymentTotalInfo = PaymentTotalInfo(payment: newPayment, totalBefore: totalBefore, totalAfter: totalAfter)
//
//                        completion(paymentTotalInfo)
//                    }
//                } catch {
//                    fatalError("Failure to save context: \(error)")
//                }
//            }
            
            
            
//            self.persistentContainer.performBackgroundTask { [weak self] context in
                
//            let newContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//            newContext.parent = self.context
//
//            newContext.performAndWait {
//                let newPayment = Payment(context: newContext)
//                newPayment.uid = UUID()
//                newPayment.amountPaid = paymentInfo.amountPaid
//                newPayment.place = paymentInfo.place
//                newPayment.date = paymentInfo.date
//                newPayment.paymentReceived = false
//
//                let receiptPhoto = ReceiptPhoto(context: newContext)
//                receiptPhoto.imageData = self.imageCompression.compressImage(for: paymentInfo.receiptImage)
//                newPayment.receiptPhoto = receiptPhoto
//
//                //                self?.saveContext()
//                self.save(newContext)
//
//                let totalAfter = totalBefore + paymentInfo.amountPaid
//
//                let paymentTotalInfo = PaymentTotalInfo(payment: newPayment, totalBefore: totalBefore, totalAfter: totalAfter)
//
//                print("----Payment: \(newPayment)")
//
//                DispatchQueue.main.async {
//                    completion(paymentTotalInfo)
//                }
//            }
            
            
            
            
            self.persistentContainer.performBackgroundTask { [unowned self] context in
                defer { print("Exiting persistentContainer background task") }
                
                let newPayment = Payment(context: context)
                newPayment.uid = UUID()
                newPayment.amountPaid = paymentInfo.amountPaid
                newPayment.place = paymentInfo.place
                newPayment.date = paymentInfo.date
                newPayment.paymentReceived = false
                
                let receiptPhoto = ReceiptPhoto(context: context)
                receiptPhoto.imageData = self.imageCompression.compressImage(for: paymentInfo.receiptImage)
                newPayment.receiptPhoto = receiptPhoto
                
                self.save(context)
                
                let totalAfter = totalBefore + paymentInfo.amountPaid
                
                let paymentTotalInfo = PaymentTotalInfo(payment: newPayment, totalBefore: totalBefore, totalAfter: totalAfter)
                
                print("----Payment: \(newPayment)")
                
                DispatchQueue.main.async {
                    completion(paymentTotalInfo)
                }
            }
            
            
            
            
            // ---- Synchronous -----
                
//            let newPayment = Payment(context: self.context)
//            newPayment.uid = UUID()
//            newPayment.amountPaid = paymentInfo.amountPaid
//            newPayment.place = paymentInfo.place
//            newPayment.date = paymentInfo.date
//            newPayment.paymentReceived = false
//
//            let receiptPhoto = ReceiptPhoto(context: self.context)
//            receiptPhoto.imageData = self.imageCompression.compressImage(for: paymentInfo.receiptImage)
//            newPayment.receiptPhoto = receiptPhoto
//
//            //                self?.saveContext()
//            self.saveContext()
//
//            let totalAfter = totalBefore + paymentInfo.amountPaid
//
//            let paymentTotalInfo = PaymentTotalInfo(payment: newPayment, totalBefore: totalBefore, totalAfter: totalAfter)
//
//            print("----Payment: \(newPayment)")
//
//            DispatchQueue.main.async {
//                completion(paymentTotalInfo)
//            }
        }
    }
    
//    private func runOnMainThread(_ closure: @escaping () ->() ) {
//        DispatchQueue.main.async {
//            closure()
//        }
//    }
    
    
    
    
    // MARK: - Get Total
    
    /**
     Gets total amount of payments asynchronously
     - Parameter sortMethod: Allows to get a total either for all, pending or received payments
     - Parameter completion: Completion handler which will be executied on main thread asynchronously
     */
    func getTotalAmountAsync(of sortMethod: PaymentStatusType, completion: @escaping (Float) -> ()) {
        
        persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let dictSumName = "sumAmount"
            
            let fetchRequest = NSFetchRequest<NSDictionary>(entityName: self.paymentsEntityName)
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
            
            
            DispatchQueue.main.async {
                completion(totalAmount)
            }
        }
    }
}

