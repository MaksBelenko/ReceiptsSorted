//
//  TextPopupViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 29/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class TextPopupViewController: UIViewController {

    var passedLabel: String = ""
    var passedNumericText: String = ""
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var numericTextField: UITextField!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPopupLook()
        
        topLabel.text = passedLabel
        numericTextField.text = passedNumericText
        
        // Force start editing text
        numericTextField.becomeFirstResponder()
    }
    
    
    
    func setupPopupLook() {
        popupView.layer.cornerRadius = 30
        insertButton.layer.cornerRadius = insertButton.frame.size.height/2
        topLabel.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }
    
    
    @IBAction func pressedInsertButton(_ sender: UIButton) {
        dismiss(animated: true, completion: onSavePressed)
    }
    
    
    func onSavePressed() {
        
    }

}
