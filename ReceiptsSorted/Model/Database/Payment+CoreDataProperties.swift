//
//  Payment+CoreDataProperties.swift
//  
//
//  Created by Maksim on 31/05/2020.
//
//

import Foundation
import CoreData


extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }

    @NSManaged public var amountPaid: Float
    @NSManaged public var date: Date?
    @NSManaged public var paymentReceived: Bool
    @NSManaged public var place: String?
    @NSManaged public var uid: UUID?
    @NSManaged public var receiptPhoto: ReceiptPhoto?

}
