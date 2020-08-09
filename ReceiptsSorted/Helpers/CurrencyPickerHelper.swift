//
//  CurrencyPickerHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

protocol CurrencyPickerDelegate: AnyObject {
    func onCurrencySelected(symbol: String, name: String)
}


class CurrencyPickerHelper: NSObject, PickerProtocol  {
    
    weak var delegate: CurrencyPickerDelegate?
    let currencies = WorldCurrencies().currencies //Locale.isoCurrencyCodes

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let symbol = currencies[row].symbol_native
        let currencyName = currencies[row].name
        delegate?.onCurrencySelected(symbol: symbol, name: currencyName)
    }
}
