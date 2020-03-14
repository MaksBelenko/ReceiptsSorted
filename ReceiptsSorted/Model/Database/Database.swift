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
    func fetchData(forName name: String) -> [Payments]{
        let request: NSFetchRequest<Payments> = Payments.fetchRequest()
        
        if (name != "") {
            //[cd] is to make it non-casesensitive and non-diacritic
            request.predicate = NSPredicate(format: "place CONTAINS[cd] %@", name)
            request.sortDescriptors = [NSSortDescriptor(key: "place", ascending: true)]
        }
        
        return loadPayments(with: request)
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
        }
        
        
        return loadPayments(with: request)
    }
    
    
    /**
     Deletes an item in the database
     - Parameter item: Item to delete from database
     */
    func delete(item: NSManagedObject) {
        context.delete(item)
        saveContext()
    }
}
