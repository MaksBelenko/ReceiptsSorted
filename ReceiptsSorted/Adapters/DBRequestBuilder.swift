//
//  DBRequestBuilder.swift
//  ReceiptsSorted
//
//  Created by Maksim on 22/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import CoreData

protocol FetchProtocol {
    associatedtype EntityType: NSFetchRequestResult
    static func createFetchRequest() -> NSFetchRequest<EntityType>
}


class DBRequestBuilder<T: NSManagedObject & FetchProtocol> {
    
    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor] = []
    

    @discardableResult
    func withPredicate(_ p: NSPredicate?) -> DBRequestBuilder {
        guard let newPredicate = p else { return self }
        if predicate == nil {
            predicate = newPredicate
        } else {
            predicate! += newPredicate
        }
        return self
    }
    
    
    @discardableResult
    func withSortDescriptor(_ sr: NSSortDescriptor?) -> DBRequestBuilder {
        guard let sortDescr = sr else { return self }
        sortDescriptors.append(sortDescr)
        return self
    }

    
    
    func build() -> NSFetchRequest<T.EntityType> {
        let request = T.createFetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
}
