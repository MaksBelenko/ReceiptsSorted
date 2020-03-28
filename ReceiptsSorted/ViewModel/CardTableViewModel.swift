//
//  CardTableViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 27/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class CardTableViewModel {
    
    /**
     Get the Sections Dictionary
     - Parameter payments: Payments the sections should be created for
     - Parameter sortedBy: Points to how sections should be created (if sorted by "Place"
                            then sections will capital letters of the places; if sorted by
                            "Date" then sections will be name of Months)
     */
    func getSections(for payments: [Payments], sortedBy: SortBy) -> [PaymentTableSection] {
        
        var sections = [PaymentTableSection]()
        
        if (sortedBy == .Place) {
            let groupedDictionary = Dictionary(grouping: payments, by: { (String($0.place!.prefix(1))).uppercased() })
            let keys = groupedDictionary.keys.sorted()
            sections = keys.map{ PaymentTableSection(key: $0, payments: groupedDictionary[$0]!) }
            
        } else {
            let calendar = Calendar.current
            let groupedDictionary = Dictionary(grouping: payments, by: { String(calendar.component(.month, from: $0.date!)) })
            let sortedKeys = (sortedBy == .NewestDateAdded) ? groupedDictionary.keys.sorted { Int($0)! > Int($1)! } : groupedDictionary.keys.sorted { Int($0)! < Int($1)! }
            sections = sortedKeys.map{ PaymentTableSection(key: Int($0)!.mapToMonth(), payments: groupedDictionary[$0]!) }
        }
        
        
        return sections
    }
}
