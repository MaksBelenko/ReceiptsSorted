//
//  CardTableViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 27/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIView

class CardTableHeader {
    
    var headerHeight: CGFloat = 40
    private let headerBackgroundColor = UIColor.whiteGrayDynColour
    private var sections = [PaymentTableSection]()
    
    
    
    //MARK: - Public methods
 
    /**
     Get the Sections Dictionary
     - Parameter payments: Payments the sections should be created for
     - Parameter sortedBy: Points to how sections should be created (if sorted by "Place"
                            then sections will capital letters of the places; if sorted by
                            "Date" then sections will be name of Months)
     */
    func getSections(for payments: [Payment], sortedBy sortMethod: SortType) -> [PaymentTableSection] {
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
    func getSectionHeaderView(for section: Int, sortedBy sortType: SortType, width: CGFloat) -> UIView {
        
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight)) //set these values as necessary
        sectionView.backgroundColor = headerBackgroundColor
        
//        let yOffset: CGFloat = (section == 0) ? 0 : 10
        
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: width, height: 20))
        label.text = getSectionTitle(for: section, sortedBy: sortType)
        label.textColor = UIColor.flatOrange // Flat UI Orange
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        sectionView.addSubview(label)
        
        
        return sectionView
    }
    
    
    
    
    //MARK: - Private methods
    
    /**
     Gets section title for the section
     - Parameter section: Section index
     - Parameter sortedBy: Sort method
     */
    private func getSectionTitle(for section: Int, sortedBy: SortType) -> String {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date()).mapToMonth()

        if (section == 0 && sortedBy == .NewestDateAdded && currentMonth == sections[0].key ) {
            return "  THIS MONTH"
        } else {
            return "  \(sections[section].key.uppercased())"
        }
    }
    
    
    
    /**
     Creates an array of PaymentTableSection sorted by place from "A" to "Z"
     - Parameter payments: Payments that are to be sorted
     */
    private func getSectionsSortedByPlace(for payments: [Payment]) -> [PaymentTableSection] {
           let groupedDictionary = Dictionary(grouping: payments, by: { (String($0.place!.prefix(1))).uppercased() })
           let keys = groupedDictionary.keys.sorted()
           return keys.map{ PaymentTableSection(key: $0, payments: groupedDictionary[$0]!) }
    }
       
       
    
    /**
     Creates an array of PaymentTableSection sorted by date either by Newest date or by Oldest date
     - Parameter payments: Payments that are to be sorted
     - Parameter sortedBy: Sorting method (only Newest and Oldest date are used)
     */
    private func getSectionsSortedByDate(for payments: [Payment], sortedBy: SortType) -> [PaymentTableSection] {
        let calendar = Calendar.current
        var tupleArray: [(month: Int, year: Int, payments: [Payment])] = []

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

        for index in 0..<tupleArray.count {
            let sortedTuplePayments = tupleArray[index].payments.sorted{ $0.date! > $1.date! }
            tupleArray[index].payments = sortedTuplePayments
        }
        
        //Creating PaymentTableSection array from tuple
        var sectionArray = [PaymentTableSection]()
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
