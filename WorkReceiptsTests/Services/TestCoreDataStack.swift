//
//  TestCoreDataStack.swift
//  CampgroundManagerTests
//
//  Created by Maksim on 15/08/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import CampgroundManager
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
  
  
  override init() {
    super.init()
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
    
    container.persistentStoreDescriptions = [persistentStoreDescription]
    
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    self.storeContainer = container
  }
  
}
