//
//  NSPredicateExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 20/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

extension NSPredicate {
    static func += (lhs: inout NSPredicate, rhs: NSPredicate?) {
        guard let addPredicate = rhs else { return }
        lhs = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, addPredicate])
    }
}
