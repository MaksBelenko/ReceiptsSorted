//
//  DatabaseFetchController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 20/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import CoreData

class DtabaseFetchController: NSObject {
    
    private let paymentsEntityName: String = "Payment"
    private let coreDataStack = CoreDataStack(modelName: "PaymentsData")
    private lazy var context = coreDataStack.managedContext
    private lazy var persistentContainer = coreDataStack.persistentContainer
    
    
    
    var dataSource: UITableViewDiffableDataSource<String, Payment>?
    var fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Payment> = {
        let dateSort = NSSortDescriptor(key: #keyPath(Payment.date), ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "paymentsCache")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
}




// MARK: - NSFetchedResultsControllerDelegate
extension DtabaseFetchController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        //    DispatchQueue.global(qos: .userInitiated).async {
        var diff = NSDiffableDataSourceSnapshot<String, Payment>()
        
        // There is a single section
        snapshot.sectionIdentifiers.forEach { section in
            
//            diff.appendSections([section as! String])
            
            let items = snapshot.itemIdentifiersInSection(withIdentifier: section).map { (objectId: Any) -> Payment in
                let oid =  objectId as! NSManagedObjectID
                return controller.managedObjectContext.object(with: oid) as! Payment
            }
            
            diff.appendItems(items, toSection: section as? String)
        }
        
        self.dataSource?.apply(diff)
        //    }
    }
}
