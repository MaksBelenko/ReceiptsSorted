//
//  PaymentViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {

    var passedImage: UIImage? = nil
    
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var amountPaidTextField: UITextField!
    @IBOutlet weak var placeOfPurchaseTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    let wetAsphaltCGColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0)
    
    
    //set Status Bar icons to white
    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        receiptImageView.image = passedImage
        
        setupTextFields()
        setupAddButton()
        
    }
    

    func setupAddButton() {
        addButton.layer.cornerRadius = addButton.frame.size.height/2
        addButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
    }
    
    
    func setupTextFields() {
        drawBottomLine(for: amountPaidTextField)
        drawBottomLine(for: placeOfPurchaseTextField)
        drawBottomLine(for: dateTextField)
        
        //Disable keyboard
        dateTextField.inputView = UIView()
    }
    
    
    func drawBottomLine(for textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = wetAsphaltCGColor.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    
    
    //MARK: - Fields actions
    
    @IBAction func startedEditingAmountPaid(_ sender: UITextField) {
        showTextPopup(label: "Amount paid:", numericText: amountPaidTextField.text ?? "")
    }
    
    
    
    @IBAction func startedEditingPlace(_ sender: UITextField) {
        showTextPopup(label: "Place of purchase:", numericText: placeOfPurchaseTextField.text ?? "")
    }
    
    
    func showTextPopup(label: String, numericText: String) {
        if let textPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextPopupViewController") as? TextPopupViewController
        {
            textPopupVC.passedLabel = label
            textPopupVC.passedNumericText = numericText
            
            textPopupVC.modalPresentationStyle = .overCurrentContext
            self.present(textPopupVC, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func startedEditingDate(_ sender: Any) {
        if let datePopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePopupViewController") as?  DatePopupViewController
        {
            datePopupVC.modalPresentationStyle = .overCurrentContext
            self.present(datePopupVC, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: - Add Button actions
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
