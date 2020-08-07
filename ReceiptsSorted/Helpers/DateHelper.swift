//
//  DateHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 02/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class DateHelper {

    let settings = SettingsUserDefaults.shared
    
    var currentDay: Int = 0
    var daysInCurrentMonth: Int = 0
    
//    private let indicatorPeriod: IndicatorPeriod
    private let currentDate = Date()
    private var onDayChanged: ((Int) -> ())?
    private enum NotificationMode {
        case Enable, Disable
    }
    
    
    // MARK: - Lifecycle
    init(/*mode indicatorPeriod: IndicatorPeriod,*/ onDayChanged: ((Int) -> ())? = nil ) {
//        self.indicatorPeriod = indicatorPeriod
        self.onDayChanged = onDayChanged
        
        setDateValues()
        dayChangedNotification(.Enable)
    }
    
    deinit {
        dayChangedNotification(.Disable)
    }
    

    
    // MARK: - Properties initialisation
    
    /**
     Sets values for the current date
     */
    private func setDateValues() {
        let calendar = Calendar.current
        let calendarDate = calendar.dateComponents([.day, .month], from: currentDate)
        currentDay = calendarDate.day!
        
        // Gets number of days in a given month
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        daysInCurrentMonth = range.count
    }
    
    
    
    // MARK: - Day change notification handler
    
    /**
     Enables or disables NSCalendarDayChanged notification if "onDayChanged" closure is set
     - Parameter mode: Either enable or disable
     */
    private func dayChangedNotification(_ mode: NotificationMode) {
        guard let _ = onDayChanged else { return }
        switch mode {
        case .Enable:
            NotificationCenter.default.addObserver(self, selector: #selector(dayDidChange), name: .NSCalendarDayChanged, object: nil)
        case .Disable:
            NotificationCenter.default.removeObserver(self, name: .NSCalendarDayChanged, object: nil)
        }
    }
    
    
    /**
     Executed when day changes (eg. midnight)
     */
    @objc private func dayDidChange(notification: NSNotification) {
        guard let onDayChanged = onDayChanged else { return }
        let newDate = Date()
        let calendarDate = Calendar.current.dateComponents([.day], from: newDate)
        
        DispatchQueue.main.async {
            onDayChanged(calendarDate.day!)
        }
    }
    
}
