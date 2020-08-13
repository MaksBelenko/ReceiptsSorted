//
//  DateHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 02/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class DateHelper {

    var currentDay: Int = 0
    var daysInCurrentPeriod: Int = 0
    
    private let settings = SettingsUserDefaults.shared
    private var indicatorPeriod: IndicatorPeriod
    private var currentDate = Date()
    /// Passes day and maxDays in current period
    private var onDayChanged: ((Int, Int) -> ())?
    private enum NotificationMode {
        case Enable, Disable
    }
    
    
    // MARK: - Lifecycle
    init( onDayChanged: ((Int, Int) -> ())? = nil ) {
        self.onDayChanged = onDayChanged
        self.indicatorPeriod = settings.getIndicatorPeriod()
        
        settings.addDateChangedListener(self)
        
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
        
        switch indicatorPeriod
        {
        case .Month:
            let calendarDate = calendar.dateComponents([.day, .month], from: currentDate)
            currentDay = calendarDate.day!
            
            // Gets number of days in a given month
            let range = calendar.range(of: .day, in: .month, for: currentDate)!
            daysInCurrentPeriod = range.count
            
        case .Week:
            daysInCurrentPeriod = 7
            let calendarDate = calendar.dateComponents([.weekday], from: currentDate)
            currentDay = (calendarDate.weekday! + 1) % 7 //Sunday == 1, Saturday == 7
        }
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
    @objc private func dayDidChange() {
        guard let onDayChanged = onDayChanged else { return }
        
        currentDate = Date()
        setDateValues()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            onDayChanged(self.currentDay, self.daysInCurrentPeriod)
        }
    }
    
}



// MARK: - DateSettingChangedProtocol
extension DateHelper: DateSettingChangedProtocol {
    
    func dateIndicatorSettingChanged(to period: IndicatorPeriod) {
        self.indicatorPeriod = period
        dayDidChange()
    }
}
