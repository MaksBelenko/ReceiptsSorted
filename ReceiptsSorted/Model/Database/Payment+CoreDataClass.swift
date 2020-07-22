//
//  Payment+CoreDataClass.swift
//  
//
//  Created by Maksim on 31/05/2020.
//
//

import Foundation
import CoreData


public class Payment: NSManagedObject, FetchProtocol {

    @nonobjc public class func fetchDictionaryRequest() -> NSFetchRequest<NSDictionary> {
        return NSFetchRequest<NSDictionary>(entityName: "Payment")
    }
    
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }
}
