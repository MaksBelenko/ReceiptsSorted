//
//  TextPopupViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit


class TextPopupViewController: UIViewController, UITextFieldDelegate {

    var passedLabel: String = ""
    var passedNumericText: String = ""
    var popupType: PopupType?
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var numericTextField: UITextField!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    var delegate: PopupDelegate?
    
    
    //"Amount paid:"
    //"Place of purchase:"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topLabel.text = (popupType! == .AmountPaid) ? "Amount paid:" : "Place of purchase:"
        
        numericTextField.delegate = self
        numericTextField.text = passedNumericText
        // Force start editing text
        numericTextField.becomeFirstResponder()
        
        setupPopupLook()
    }
    
    
    
    func setupPopupLook() {
        popupView.layer.cornerRadius = 30
        insertButton.layer.cornerRadius = insertButton.frame.size.height/2
        topLabel.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }
    
    
    @IBAction func pressedInsertButton(_ sender: UIButton) {
        onDismissVC()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onDismissVC()
        return false
    }
    
    
    func onDismissVC() {
        
        if (popupType! == .AmountPaid) {
            delegate?.setAmountPaidValue(value: numericTextField.text!)
        } else {
            delegate?.setPlaceValue(value: numericTextField.text!)
        }
        
        dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    

}
