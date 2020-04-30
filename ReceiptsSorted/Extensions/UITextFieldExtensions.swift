//
//  UITextFieldExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 25/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
extension UITextField {
    
    /// Create a UIDatePicker object and assign to inputView
    func setInputViewDatePicker(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    
    ///Sets parameters for AmountPaid TextField in PaymentVC
    func setInputAmountPaid() {
        leftViewMode = .always
        
        let currencyLabel = UILabel()
        currencyLabel.text = "£ "
        currencyLabel.textColor = .wetAsphalt
        currencyLabel.font = UIFont(name: "Arial", size: 20)
        currencyLabel.textAlignment = .center
        leftView = currencyLabel
        
        keyboardType = .decimalPad
        
        let screenWidth = UIScreen.main.bounds.width
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(tapCancel))
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    
    
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
}
