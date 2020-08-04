//
//  SwttingsUserDefaults.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation


enum IndicatorPeriod: Int {
    case Week = 0
    case Month = 1
}


class SettingsUserDefaults {
    
    static let shared = SettingsUserDefaults()
    private let periodKey = "period"
    private let multicastDelegate = MulticastDelegate<DateSettingChangedProtocol>()

    /**
     Set write to UserDefaults the date indicator period.
     - Parameter period: Enum that represents what period should be set.
     */
    func setIndicatorPeriod(to period: IndicatorPeriod) {
        let value = period.rawValue
        UserDefaults.standard.set(value, forKey: periodKey)
        invokePeriodDelegates(with: period)
    }
    
    
    /**
     Gets date indicator period
     - Returns: Either a week or a month depending on what was saved in UserDefaults
     */
    func getIndicatorPeriod() -> IndicatorPeriod {
        let value = UserDefaults.standard.integer(forKey: periodKey)
        return (value == IndicatorPeriod.Week.rawValue) ? .Week : .Month
    }
}


// MARK: - Multicast extension
extension SettingsUserDefaults {
    
    /**
     Adds a delegate which will listen to changes for the date period
     - Parameter object: Object that will listen to changes
     */
    func addDateChangedListener(_ object: DateSettingChangedProtocol) {
        multicastDelegate.addDelegate(object)
    }
    
    /**
     Invokes all the delegates with changes
     - Parameter period: New period that is being saved to UserDefaults
     */
    private func invokePeriodDelegates(with period: IndicatorPeriod) {
        multicastDelegate.invokeDelegates {
            $0.dateIndicatorSettingChanged(to: period)
        }
    }
    
    /**
     Removes listener from date changed delegates
     - Parameter object: Object to be removed
     */
    func removeDateListener(_ object: DateSettingChangedProtocol) {
        multicastDelegate.removeDelegate(object)
    }
}
