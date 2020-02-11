//
//  PaymentViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import Vision

class PaymentViewController: UIViewController {

    var pageType: ShowPaymentAs = .AddPayment
    
    var passedImage: UIImage? = nil
    var amountPaid: String = ""
    var place: String = ""
    var date: String = ""
    
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var amountPaidTextField: UITextField!
    @IBOutlet weak var placeOfPurchaseTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    let wetAsphaltCGColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0)
    
    var paymentDelegate: PaymentDelegate?
    
    var formattedDateToday: String {
        get {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: Date())
        }
    }
    
    
    //set Status Bar icons to black
    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        receiptImageView.image = passedImage
        setTextFields()
        
        setupTextFields()
        setupAddButton()
        
    }
    

    
    func setTextFields() {
        placeOfPurchaseTextField.text = place
        
        if (pageType == .UpdatePayment) {
            amountPaidTextField.text = amountPaid
            dateTextField.text = date
        }
        
        if (pageType == .AddPayment) {
            amountPaidTextField.text = "£0.00"
            dateTextField.text = formattedDateToday
        }
    }
    
    
    
    
    func setupAddButton() {
        addButton.layer.cornerRadius = addButton.frame.size.height/2
        addButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
        
        let buttonTitle = (pageType == .AddPayment) ? "Add" : "Save"
        addButton.setTitle( buttonTitle, for: .normal)
    }
    
    
    
    func setupTextFields() {
        drawBottomLine(for: amountPaidTextField)
        drawBottomLine(for: placeOfPurchaseTextField)
        drawBottomLine(for: dateTextField)
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
        showTextPopup(popupType: .AmountPaid, numericText: amountPaidTextField.text ?? "")
    }
    
    
    @IBAction func startedEditingPlace(_ sender: UITextField) {
        showTextPopup(popupType: .Place, numericText: placeOfPurchaseTextField.text ?? "")
    }
    
    
    func showTextPopup(popupType: PopupType, numericText: String) {
        if let textPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextPopupViewController") as? TextPopupViewController
        {
            textPopupVC.popupType = popupType
            textPopupVC.passedNumericText = numericText
            
            textPopupVC.delegate = self
            textPopupVC.modalPresentationStyle = .overCurrentContext
            self.present(textPopupVC, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func startedEditingDate(_ sender: Any) {
        dateTextField.resignFirstResponder()
        
        if let datePopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePopupViewController") as?  DatePopupViewController
        {
            datePopupVC.delegate = self
            datePopupVC.modalPresentationStyle = .overCurrentContext
            self.present(datePopupVC, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: - Add Button actions
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        paymentDelegate?.passData(amountPaid: amountPaidTextField.text!, place: placeOfPurchaseTextField.text!, date: dateTextField.text!, receiptImage: receiptImageView.image ?? UIImage())
        
        if (pageType == .AddPayment) {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    //MARK: - Text detection
    
    @IBAction func pressedDetectTextButton(_ sender: UIButton) {
     
        let textRecogniser = TextRecogniser()
        let text = textRecogniser.findReceiptDetails(for: passedImage!)
        amountPaidTextField.text = text
    }
        

}





//MARK:- Extensions
extension PaymentViewController: PopupDelegate {
    
    func setAmountPaidValue(value: String) {
        amountPaidTextField.text = value
    }
    func setPlaceValue(value: String) {
        placeOfPurchaseTextField.text = value
    }
    func setDatepopupValue(value: String) {
        dateTextField.text = value
    }
    
}
