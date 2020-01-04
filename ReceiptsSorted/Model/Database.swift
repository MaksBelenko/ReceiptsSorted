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
    
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error found: \(error)")
        }
    }
    
    
    func loadPayments() -> [Payments] {
        let request: NSFetchRequest<Payments> = Payments.fetchRequest()
        
        do {
           return try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
            return []
        }
    }
}
