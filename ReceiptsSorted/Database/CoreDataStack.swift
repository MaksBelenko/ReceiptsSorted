//
//  CoreDataStack.swift
//  ReceiptsSorted
//
//  Created by Maksim on 19/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String

    lazy var managedContext: NSManagedObjectContext = {
//        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return self.persistentContainer.viewContext
    }()

    
    // MARK: - Initialisation
    init(modelName: String) {
      self.modelName = modelName
    }
    
    

   // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
