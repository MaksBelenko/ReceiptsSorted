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
    private var fetchLimit = 0 // 0 -> Unlimited results
    private var fetchOffset = 0

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
    
    
    @discardableResult
    func withFetchLimit(_ limit: Int) -> DBRequestBuilder {
        fetchLimit = limit
        return self
    }
    

    @discardableResult
    func withFetchOffset(_ offset: Int) -> DBRequestBuilder {
        fetchOffset = offset
        return self
    }
    
    
    func build() -> NSFetchRequest<T.EntityType> {
        let request = T.createFetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = fetchLimit
        request.fetchOffset = fetchOffset
        return request
    }
}
