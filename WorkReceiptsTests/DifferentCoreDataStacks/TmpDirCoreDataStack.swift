//
//  NewDirCoreDataStack.swift
//  WorkReceiptsTests
//
//  Created by Maksim on 17/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation
import CoreData
@testable import WorkReceipts

/**
 Uses /dev/null directory for tests ensuring that it will be recreated every time
 */
class TmpDirCoreDataStack: CoreDataStack {
  
    
    override init() {
        super.init()
        
        // Clean Tmp directory before tests
        FileManager.default.cleanTmpDirectory()
        
        let container = NSPersistentContainer(name: CoreDataStack.modelName)
        let storeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(CoreDataStack.modelName).sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.persistentContainer = container
    }
    
}
