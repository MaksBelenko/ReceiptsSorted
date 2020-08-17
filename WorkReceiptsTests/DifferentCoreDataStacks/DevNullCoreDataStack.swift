//
//  TmpDirCoreDataStack.swift
//  WorkReceiptsTests
//
//  Created by Maksim on 17/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation
import CoreData
@testable import WorkReceipts


/**
 Uses temprorary directory for sqlite database files
 */
class DevNullCoreDataStack: CoreDataStack {
  
  
  override init() {
    super.init()
    
    let container = NSPersistentContainer(name: CoreDataStack.modelName)
    let devNullDir = URL(fileURLWithPath: "/dev/null")
    print(devNullDir)
    container.persistentStoreDescriptions[0].url = devNullDir
    container.loadPersistentStores { (description, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    self.persistentContainer = container
  }
  
}
