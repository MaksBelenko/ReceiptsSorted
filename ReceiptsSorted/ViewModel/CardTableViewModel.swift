//
//  CardTableViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 27/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class CardTableViewModel {
    
    var headerHeight: CGFloat = 40
    private var sections = [PaymentTableSection]()
    
    
    
    //MARK: - Public methods
    
    /**
     Get the Sections Dictionary
     - Parameter payments: Payments the sections should be created for
     - Parameter sortedBy: Points to how sections should be created (if sorted by "Place"
                            then sections will capital letters of the places; if sorted by
                            "Date" then sections will be name of Months)
     */
    func getSections(for payments: [Payments], sortedBy sortMethod: SortBy) -> [PaymentTableSection] {
        if (sortMethod == .Place) {
            sections = getSectionsSortedByPlace(for: payments)
        } else {
            sections = getSectionsSortedByDate(for: payments, sortedBy: sortMethod)
        }
        
        return sections
    }
    
    
    
    
    /**
     Creates a view for the Header of the Section
     - Parameter section: Section index
     - Parameter sortedBy: Sort method
     - Parameter width: Width of the section header view
     */
    func getSectionHeaderView(for section: Int, sortedBy: SortBy, width: CGFloat) -> UIView {
        
        headerHeight = (section == 0) ? 30 : 40
        
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight)) //set these values as necessary
        sectionView.backgroundColor = .white
        
        let yOffset: CGFloat = (section == 0) ? 0 : 10
        
        let label = UILabel(frame: CGRect(x: 0, y: yOffset, width: width, height: 30))
        label.text = getSectionTitle(for: section, sortedBy: sortedBy)
        label.textColor = UIColor(rgb: 0xEDB200) // Flat UI Orange
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        sectionView.addSubview(label)
        
        
        return sectionView
    }
    
    
    
    
    //MARK: - Private methods
    
    /**
     Gets section title for the section
     - Parameter section: Section index
     - Parameter sortedBy: Sort method
     */
    func getSectionTitle(for section: Int, sortedBy: SortBy) -> String {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date()).mapToMonth()

        if (section == 0 && sortedBy == .NewestDateAdded && currentMonth == sections[0].key ) {
            return "    This month"
        } else {
            return "    \(sections[section].key)"
        }
    }
    
    
    
    /**
     Creates an array of PaymentTableSection sorted by place from "A" to "Z"
     - Parameter payments: Payments that are to be sorted
     */
    private func getSectionsSortedByPlace(for payments: [Payments]) -> [PaymentTableSection] {
           let groupedDictionary = Dictionary(grouping: payments, by: { (String($0.place!.prefix(1))).uppercased() })
           let keys = groupedDictionary.keys.sorted()
           return keys.map{ PaymentTableSection(key: $0, payments: groupedDictionary[$0]!) }
    }
       
       
    
    /**
     Creates an array of PaymentTableSection sorted by date either by Newest date or by Oldest date
     - Parameter payments: Payments that are to be sorted
     - Parameter sortedBy: Sorting method (only Newest and Oldest date are used)
     */
    private func getSectionsSortedByDate(for payments: [Payments], sortedBy: SortBy) -> [PaymentTableSection] {
        let calendar = Calendar.current
        var tupleArray: [(month: Int, year: Int, payments: [Payments])] = []

        //Creating a dictionary with "Year" to be a key
        let yearGroupedPayments = Dictionary(grouping: payments, by: { calendar.component(.year, from: $0.date!) })

        //Adding to tuple all payments that have the same "month" and "year"
        for yearDictionary in yearGroupedPayments {
           let monthGroupedPayments = Dictionary(grouping: yearDictionary.value, by: { (calendar.component(.month, from: $0.date!)) })
           for monthDictionary in monthGroupedPayments {
               tupleArray.append((month: monthDictionary.key, year: yearDictionary.key, payments: monthDictionary.value))
           }
        }

        //Sorting tuple
        if (sortedBy == .NewestDateAdded) {
           tupleArray.sort { $0.month > $1.month }
           tupleArray.sort { $0.year > $1.year }
        } else {
           tupleArray.sort { $0.month < $1.month }
           tupleArray.sort { $0.year < $1.year }
        }

        
        //Creating PaymentTableSection array from tuple
        var sectionArray = [PaymentTableSection]()
//        let todayMonth = calendar.component(.month, from: Date())
        let todayYear = calendar.component(.year, from: Date())
        for p in tupleArray {
            if (p.year == todayYear) {
                sectionArray.append(PaymentTableSection(key: p.month.mapToMonth(), payments: p.payments))
            } else {
                sectionArray.append(PaymentTableSection(key: "\(p.month.mapToMonth()) \(p.year)", payments: p.payments))
            }
        }

        return sectionArray
    }
    
}
