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
    
    fileprivate lazy var paymentsEntityName = Payment.entity().name! //"Payment"
    let fetchLimit = 100
    
    typealias CompletionHandler = ([Payment]) -> ()
    
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
    
    
    
    
    // MARK: - Basic saving
    
    /**
     Save specified context. It ensures that it will be saved in the same thread on which it was
     created.
     - Parameter context: Context to be saved
     */
    private func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    var message = "Error found when saving context: \(error.localizedDescription)  \n Callstack:"
                    for symbol: String in Thread.callStackSymbols {
                        message += "\n > \(symbol)"
                    }
                    Log.exception(message: message)
                }
            }
        }
    }
    
    
    
    // MARK: - Deletion
    
    /**
     Deletes an item in the database
     - Parameter item: Item to delete from database
     - Parameter completion: Completion handler to be executed after the item
                             is deleted asynchrnously on the main thread async
     */
    func deleteAsync<T: NSManagedObject>(item: T, completion: (() -> ())? = nil) {
        let objectID = item.objectID  // Cannot remove NSManagedObject on a different
                                      // thread therefore it needs an object id of it
        
        persistentContainer.performBackgroundTask { [unowned self] privateContext in
            let object = privateContext.object(with: objectID)
            privateContext.delete(object)
            self.save(privateContext)
            
            guard let completion = completion else { return }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
    
    // MARK: - Asynchronous fetching
    
    /**
     Executes asynchronous fetch with the passed request
     - Parameter request: Request to be fetched with (default is empty fetch request)
     - Parameter completion: Completion handler to be executed after the payments
                             are fetched asynchronously
     */
    private func loadAsync<T>(with request: NSFetchRequest<T>, completion: @escaping ([T]) -> ()) {
        let asyncFetchRequest = NSAsynchronousFetchRequest<T>( fetchRequest: request) { /*[unowned self]*/ (result: NSAsynchronousFetchResult) in
            guard let fetchedArrayResults = result.finalResult else { return }
            completion(fetchedArrayResults)
        }

        do {
            try context.execute(asyncFetchRequest)
        } catch {
            Log.exception(message: "Error executing asynchronous fetch: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Fetch
    
    /**
     Fetch all payments from database which contain the passed place name
     - Parameter name: Optional string that is used to search payments in
                       the database (Default value is nil)
     - Parameter sort: General sorting of all payments (eg. sort by .NewestDate)
     - Parameter paymentStatus: Payment status (eg. .Pending)
     - Parameter completion: Completion handler to be executed after the payments
                             are fetched asynchronously
     */
    func fetchDataAsync(offset: Int = 0, forName name: String? = nil, by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping CompletionHandler) {
        let request = createFetchRequest(offset: offset, forName: name, by: sort, and: paymentStatus)
        loadAsync(with: request, completion: completion)
    }
    
    
    /**
     Fetches more entries from database with offset
     - Parameter offset: Offset for fetch request in the database
     - Parameter name: Optional string that is used to search payments in
                       the database (Default value is nil)
     - Parameter sort: General sorting of all payments (eg. sort by .NewestDate)
     - Parameter paymentStatus: Payment status (eg. .Pending)
     - Parameter completion: Completion handler to be executed after the payments
                             are fetched asynchronously
     */
    func fetchMoreDataAsync(offset: Int = 0, forName name: String? = nil, by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping (Int, [Payment]) -> ()) {
        let request = createFetchRequest(offset: offset, forName: name, by: sort, and: paymentStatus)

        countPayments(predicate: request.predicate, sortDescriptors: request.sortDescriptors) { [unowned self] count in
            let leftToFetch = count - offset
            if ( leftToFetch == 0 ) {
                completion(0, [])
                return
            }
            self.loadAsync(with: request) { payments in
                completion(payments.count, payments)
            }
        }
    }
    
    private func createFetchRequest(offset: Int = 0, forName name: String? = nil, by sort: SortType, and paymentStatus: PaymentStatusType) -> NSFetchRequest<Payment> {
        let reqBuilder = DBRequestBuilder<Payment>()
                            .withFetchLimit(fetchLimit)
                            .withFetchOffset(offset)
                            .withPredicate(paymentStatus.getPredicate())
                            .withSortDescriptor(sort.getSortDescriptor())
        
        if (name != "" && name != nil) {
            //[cd] is to make it non-casesensitive and non-diacritic
            reqBuilder.withPredicate(NSPredicate(format: "place CONTAINS[cd] %@", name!))
            reqBuilder.withSortDescriptor(placeSortDescriptor)
        }
        
        return reqBuilder.build()
    }
    
    
    
    
    // MARK: - UUID related fetching
    
    /**
     Fetch the payment with matches single uid
     - Parameter uid: UID used to find in database
     - Parameter completion: Completion handler to be executed after the payment
                             is fetched asynchronously
     */
    func fetchSinglePaymentAsync(with uid: UUID, completion: @escaping (Payment) -> ()) {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Payment.uid), uid as CVarArg)
        
        loadAsync(with: request) { payments in
            completion(payments.first!)
        }
    }
    
    
    /**
     Fetches data from the array of UIDs of the payments
     - Parameter uidArray: Array of UIDs
     - Parameter completion: Completion handler to be executed after the payments
                             are fetched asynchronously
     */
    func fetchDataAsync(containingUIDs uidArray: [UUID], completion: @escaping CompletionHandler){
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(Payment.uid), uidArray)
        
        loadAsync(with: request, completion: completion)
    }
    
    
    /**
     Get all UIDs from database
     - Parameter paymentStatus: Get uids for payments with the passed payment status
     - Parameter completion: Completion closure to be executed after the fetch with the fetched uids
     */
    func getAllUids(for paymentStatus: PaymentStatusType, completion: @escaping ([UUID]) -> ()) {
        var uids = [UUID]()
        let uidKeyPath = #keyPath(Payment.uid)
        
        let fetchRequest = Payment.fetchDictionaryRequest()
        fetchRequest.predicate = paymentStatus.getPredicate()
        fetchRequest.propertiesToFetch = [uidKeyPath]
        fetchRequest.resultType = .dictionaryResultType
        
        loadAsync(with: fetchRequest) { results in
            results.forEach { uids.append($0[uidKeyPath] as! UUID) }
//            print("Printing fetched uids:\n \(uids)")
            completion(uids)
        }
    }
    
    
    //MARK: - Add methods
    
    /**
     Adds a payments to database and returns a tuple of the totals before and after the payment
     - Parameter paymentInfo: Tuple that is used to create a new entry in the database
     */
    func addAsync (paymentInfo: PaymentInformation, completion: @escaping (PaymentTotalInfo) -> ()) {
        
        getTotalAmountAsync(of: .Pending) { [unowned self] totalBefore in
            
            let compressionRate = self.settings.compression
            self.persistentContainer.performBackgroundTask { [unowned self] context in
//                defer { print("Exiting persistentContainer background task") }
                let generatedUUID = UUID()
                
                let newPayment = Payment(context: context)
                newPayment.uid = generatedUUID
                newPayment.amountPaid = paymentInfo.amountPaid
                newPayment.place = paymentInfo.place
                newPayment.date = paymentInfo.date
                newPayment.paymentReceived = false
                
                let receiptPhoto = ReceiptPhoto(context: context)
                receiptPhoto.imageData = self.imageCompression.compressImage(for: paymentInfo.receiptImage, withCompression: compressionRate)
                newPayment.receiptPhoto = receiptPhoto
                
                self.save(context)
                
                let totalAfter = totalBefore + paymentInfo.amountPaid
                
                let paymentTotalInfo = PaymentTotalInfo(uid: generatedUUID, totalAfter: totalAfter)
                
//                print("----Payment: \(newPayment)")
                
                DispatchQueue.main.async {
                    completion(paymentTotalInfo)
                }
            }
        }
    }
    
    
    // MARK: - Update methods
    
    /**
     Updates a payments with the information passed in tuple
     - Parameter payment: Payment from the database to be updated
     - Parameter paymentInfo: Tuple used to update the payment information
     */
    func updateAsync(payment: Payment, with paymentInfo: PaymentInformation, completion: @escaping (PaymentTotalInfo) -> ()) {
        let compressionRate = settings.compression
        
        persistentContainer.performBackgroundTask { [unowned self] privateContext in
            payment.receiptPhoto?.imageData = paymentInfo.receiptImage.jpegData(compressionQuality: compressionRate)
            payment.amountPaid = paymentInfo.amountPaid
            payment.place = paymentInfo.place
            payment.date = paymentInfo.date
            
            self.save(privateContext)
            self.save(self.context) // save main parent context
            
            self.getTotalAmountAsync(of: .Pending) { totalAfter in
                let info = PaymentTotalInfo(uid: payment.uid!, totalAfter: totalAfter)
                completion(info)
            }
        }
    }
    
    
    
    /**
     Update individual attribute of payment in the database
     - Parameter payment: Entry to update
     - Parameter detailType: Enum of the attributes
     - Parameter newDetail: Value that the attribute of the entry should be updated with.
                            AmountPaid -> Float; Place -> String; ReceiptPhoto -> Data;
                            PaymentReceived -> Bool
     */
    func updateFieldAsync(for payment: Payment, fieldType: PaymentField, with newDetail: Any, completion: @escaping () -> ()) {
        persistentContainer.performBackgroundTask { [unowned self] privateContext in
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
            
            self.save(privateContext)
            self.save(self.context) // save main parent context
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    
    // MARK: - Get Total
    
    /**
     Gets total amount of payments asynchronously
     - Parameter sortMethod: Allows to get a total either for all, pending or received payments
     - Parameter completion: Completion handler which will be executied on main thread asynchronously
     */
    func getTotalAmountAsync(of sortMethod: PaymentStatusType, completion: @escaping (Float) -> ()) {
        
        persistentContainer.performBackgroundTask { /*[unowned self]*/ context in
            let dictSumName = "sumAmount"
            
            let fetchRequest = Payment.fetchDictionaryRequest()
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
                Log.exception(message: "Error retrieving total amount. Error: \(error.localizedDescription)")
            }
            
            
            DispatchQueue.main.async {
                completion(totalAmount)
            }
        }
    }
    
    
    func countPayments(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: @escaping (Int) -> ()) {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: paymentsEntityName)
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        persistentContainer.performBackgroundTask { newContext in
            var count = 0
            do {
                let countResult = try newContext.fetch(fetchRequest)
                count = countResult.first!.intValue
            } catch let error as NSError {
                print("count not fetched \(error), \(error.userInfo)")
            }

            completion(count)
        }
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

}




