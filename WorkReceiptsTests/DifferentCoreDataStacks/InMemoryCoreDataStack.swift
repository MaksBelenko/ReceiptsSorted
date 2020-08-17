//
//  TestCoreDataStack.swift
//  CampgroundManagerTests
//
//  Created by Maksim on 15/08/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation
import CoreData
@testable import WorkReceipts

class InMemoryCoreDataStack: CoreDataStack {
  
  
  override init() {
    super.init()
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(name: CoreDataStack.modelName)
    
    container.persistentStoreDescriptions = [persistentStoreDescription]
    
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    self.persistentContainer = container
  }
  
}
