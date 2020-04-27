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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imageCompression = ImageCompression()
    
    
    
    
    
    //MARK: - Save and Delete Methods
    
    /**
     Attempts to commit unsaved changes to registered objects to the context’s parent store.
     */
    func saveContext() {
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
    
    
    
    //MARK: - Fetch methods
    
    /**
     Get all payments from database
     - Parameter request: NSFetchRequest that is used to fetch data from database
     */
    func loadPayments(with request: NSFetchRequest<Payments> = Payments.fetchRequest()) -> [Payments] {
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
            return []
        }
    }
    
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
            
            var predicatePaymentReceived: NSPredicate?
            switch paymentStatus
            {
            case .Pending:
                predicatePaymentReceived = NSPredicate(format: "paymentReceived == %@", NSNumber(value: false))
            case .Received:
                predicatePaymentReceived = NSPredicate(format: "paymentReceived == %@", NSNumber(value: true))
            case .All:
                break
            }
            
            if let secondPredicate = predicatePaymentReceived {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateSearchName, secondPredicate])
            } else {
                request.predicate = predicateSearchName
            }
            
            
            request.sortDescriptors = [NSSortDescriptor(key: "place", ascending: true)]
            
            
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
        
        switch paymentStatus
        {
        case .Pending:
            request.predicate = NSPredicate(format: "paymentReceived == %@", NSNumber(value: false))
        case .Received:
            request.predicate = NSPredicate(format: "paymentReceived == %@", NSNumber(value: true))
        case .All:
            break
        }
        
        
        switch sort
        {
        case .Place:
            request.sortDescriptors = [NSSortDescriptor(key: "place", ascending: true)]
        case .NewestDateAdded:
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        case .OldestDateAdded:
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        case .None:
            break
        }
        
        
        return loadPayments(with: request)
    }
    
    
    
    
    
    //MARK: - Add & Update Payment methods
    
    /**
     Adds a payments to database and returns a tuple of the totals before and after the payment
     - Parameter payment: Tuple that is used to create a new entry in the database
     */
    func add (payment: (amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) -> (totalBefore: Float, totalAfter: Float) {
        let newPayment = Payments(context: context)
        newPayment.amountPaid = payment.amountPaid
        newPayment.place = payment.place
        newPayment.date = payment.date
        newPayment.receiptPhoto = imageCompression.compressImage(for: payment.receiptImage)
        newPayment.paymentReceived = false

        saveContext()
       
        let totalAfter = getTotalAmount(of: .Pending)
        return (totalBefore: totalAfter - newPayment.amountPaid, totalAfter: totalAfter)
    }
    
    
    /**
     Updates a payments with the information passed in tuple
     - Parameter payment: Payment from the database to be updated
     - Parameter dataTuple: Tuple used to update the payment information
     */
    func update(payment: Payments, with dataTuple: (amountPaid: Float, place: String, date: Date, receiptImage: UIImage)) {
        payment.receiptPhoto = dataTuple.receiptImage.jpegData(compressionQuality: 1)
        payment.amountPaid = dataTuple.amountPaid
        payment.place = dataTuple.place
        payment.date = dataTuple.date
        
        saveContext()
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
            payment.receiptPhoto = newDetail as? Data
        case .PaymentReceived:
            payment.paymentReceived = newDetail as! Bool
        }
        
        saveContext()
    }
    
    
    
    
    
    /**
     Gets total amount of payments
     - Parameter sortMethod: Allows to get a total either for all, pending or received payments
     */
    func getTotalAmount(of sortMethod: PaymentStatusSort) -> Float {
        let payments = fetchSortedData(by: .None, and: sortMethod)
        let totalAmount = payments.map({ $0.amountPaid }).reduce(0,+)
        
        return totalAmount
    }
}
