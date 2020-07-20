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
    func fetchSortedDataAsync(by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping CompletionHandler) {
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
     - Parameter name: Place's name that is used to filter and fetch data
                       from database
     */
    func fetchDataAsync(forName name: String?, by sort: SortType, and paymentStatus: PaymentStatusType, completion: @escaping CompletionHandler){
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        if (name != "" && name != nil) {
            //[cd] is to make it non-casesensitive and non-diacritic
            request.predicate = NSPredicate(format: "place CONTAINS[cd] %@", name!)
            request.predicate! += paymentStatus.getPredicate()
            
            request.sortDescriptors = [placeSortDescriptor]
            loadPaymentsAsync(with: request, completion: completion)
        } else {
            fetchSortedDataAsync(by: sort, and: paymentStatus, completion: completion)
        }
    }
    
    
    
    
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

