//
//  ReceiptRemovalPickerHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

protocol ReceiptRemovalPickerDelegate: AnyObject {
    func onRemoveOptionSelected(afterMonths monthsNumber: Int)
}


class ReceiptRemovalPickerHelper: NSObject, PickerProtocol {
    
    weak var delegate: ReceiptRemovalPickerDelegate?
    let removeOptions = [(value: -1, name: "Disable"),
                         (value:  1, name: "After 1 month"),
                         (value:  2, name: "After 2 months"),
                         (value:  3, name: "After 3 months"),
                         (value:  6, name: "After 6 months"),
                         (value: 12, name: "After 1 year")   ]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return removeOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return removeOptions[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.onRemoveOptionSelected(afterMonths: removeOptions[row].value)
    }
}
