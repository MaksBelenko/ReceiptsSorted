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
    
    private let currencySymbolKey = "currencySymbolKey"
    private let currencyNameKey = "currencyNameKey"
    private let currencyMulticastDelegate = MulticastDelegate<CurrencyChangedProtocol>()
    
    private let periodKey = "period"
    private let dateMulticastDelegate = MulticastDelegate<DateSettingChangedProtocol>()

    
    
    // MARK: - Currency
    
    func setDefaultCurrency(to currencySymbol: String, currencyName: String) {
        UserDefaults.standard.set(currencySymbol, forKey: currencySymbolKey)
        UserDefaults.standard.set(currencyName, forKey: currencyNameKey)
        invokeCurrencyDelegates(with: currencySymbol, name: currencyName)
    }
    
    func getCurrency() -> (symbol: String?, name: String?) {
        let currencySymbol = UserDefaults.standard.string(forKey: currencySymbolKey)
        let currencyName = UserDefaults.standard.string(forKey: currencyNameKey)
        return (symbol: currencySymbol, name: currencyName)
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
    private func invokeCurrencyDelegates(with currencySymbol: String, name currencyName: String) {
        currencyMulticastDelegate.invokeDelegates {
            $0.currencySettingChanged(to: currencySymbol, name: currencyName)
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
