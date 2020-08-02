//
//  DateHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 02/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class DateHelper {

    var currentDay: Observable<Int> = Observable(0)
    var daysInCurrentMonth: Int = 0
    
    private let currentDate = Date()
    
    
    // MARK: - Lifecycle
    init() {
        setDateValues()
        NotificationCenter.default.addObserver(self, selector: #selector(onDayChanged), name: .NSCalendarDayChanged, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSCalendarDayChanged, object: nil)
    }
    
    

    
    // MARK: - Day change notification handler
    
    /**
     Executed when day changes (eg. midnight)
     */
    @objc private func onDayChanged() {
        
    }
    
    
    // MARK: - Properties initialisation
    
    /**
     Sets values for the current date
     */
    private func setDateValues() {
        let calendar = Calendar.current
        let calendarDate = calendar.dateComponents([.day, .month], from: currentDate)
        currentDay.value = calendarDate.day!
        
        // Gets number of days in a given month
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        daysInCurrentMonth = range.count
    }
}
