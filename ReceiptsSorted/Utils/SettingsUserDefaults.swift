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
    
    private let currencyKey = "currencyKey"
    private let currencyMulticastDelegate = MulticastDelegate<CurrencyChangedProtocol>()
    
    private let periodKey = "period"
    private let dateMulticastDelegate = MulticastDelegate<DateSettingChangedProtocol>()

    
    
    // MARK: - Currency
    
    func setDefaultCurrency(to currencySymbol: String) {
        UserDefaults.standard.set(currencySymbol, forKey: currencyKey)
        invokeCurrencyDelegates(with: currencySymbol)
    }
    
    func getCurrency() -> String? {
        let currencySymbol = UserDefaults.standard.string(forKey: currencyKey)
        return currencySymbol
    }
    
    
    // MARK: - Date indicator
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



// MARK: - Currency Multicast extension
extension SettingsUserDefaults {
    
    /**
     Adds a delegate which will listen to changes for the date period
     - Parameter object: Object that will listen to changes
     */
    func addCurrencyChangedListener(_ object: CurrencyChangedProtocol) {
        currencyMulticastDelegate.addDelegate(object)
    }
    
    /**
     Removes listener from date changed delegates
     - Parameter object: Object to be removed
     */
    func removeCurrencyListener(_ object: CurrencyChangedProtocol) {
        currencyMulticastDelegate.removeDelegate(object)
    }
    
    
    /**
     Invokes all the delegates with changes
     - Parameter period: New period that is being saved to UserDefaults
     */
    private func invokeCurrencyDelegates(with currencyLabel: String) {
        currencyMulticastDelegate.invokeDelegates {
            $0.currencySettingChanged(to: currencyLabel)
        }
    }
}




// MARK: - Date Indicator Multicast extension
extension SettingsUserDefaults {
    
    /**
     Adds a delegate which will listen to changes for the date period
     - Parameter object: Object that will listen to changes
     */
    func addDateChangedListener(_ object: DateSettingChangedProtocol) {
        dateMulticastDelegate.addDelegate(object)
    }
    
    /**
     Removes listener from date changed delegates
     - Parameter object: Object to be removed
     */
    func removeDateListener(_ object: DateSettingChangedProtocol) {
        dateMulticastDelegate.removeDelegate(object)
    }
    
    
    /**
     Invokes all the delegates with changes
     - Parameter period: New period that is being saved to UserDefaults
     */
    private func invokePeriodDelegates(with period: IndicatorPeriod) {
        dateMulticastDelegate.invokeDelegates {
            $0.dateIndicatorSettingChanged(to: period)
        }
    }
}
