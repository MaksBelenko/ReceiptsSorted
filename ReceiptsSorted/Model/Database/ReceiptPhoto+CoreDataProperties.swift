//
//  ReceiptPhoto+CoreDataProperties.swift
//  
//
//  Created by Maksim on 31/05/2020.
//
//

import Foundation
import CoreData


extension ReceiptPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiptPhoto> {
        return NSFetchRequest<ReceiptPhoto>(entityName: "ReceiptPhoto")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var payment: Payment?

}
