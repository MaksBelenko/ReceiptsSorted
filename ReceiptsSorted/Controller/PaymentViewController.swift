//
//  PaymentViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import Vision
import CropViewController

class PaymentViewController: UIViewController, UITextFieldDelegate {

    var paymentAction: PaymentAction = .AddPayment
    var passedImage: UIImage? = nil
    
    var paymentUID: UUID!
    var amountPaid: Float = 0.0
    var place: String = ""
    var date: Date = Date()
    var currencySymbol: String = ""
    var currencyName: String = ""
    
    let notificationCenter = NotificationCenter.default
    private let settings = SettingsUserDefaults.shared
    private let buttonAnimations = AddButtonAnimations()
    private let imageGesturesViewModel = ImageGestures()
    
    
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var amountPaidTextField: UITextField!
    @IBOutlet weak var placeOfPurchaseTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    
    //set Status Bar icons to black
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    // MARK: - Deinit
    deinit {
        #if DEBUG
            print("DEBUG: PaymentViewController deinit")
        #endif
    }
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        receiptImageView.image = passedImage
    
        setupNavigationBar()
        
        bottomView.layer.cornerRadius = 13
        bottomView.layer.applyShadow(color: .black, alpha: 0.2, x: 0, y: -3, blur: 4)
        
        setTextFields()
        setupTextFields()
        setupAddButton()
        setupGestures()
        configureColors()
        
        amountPaidTextField.delegate = self
        placeOfPurchaseTextField.delegate = self
    
        dateTextField.setInputViewDatePicker(target: self, selector: #selector(pressedDoneDatePicker))
        
        if paymentAction == .AddPayment {
            let tuple = settings.getCurrency()
            currencySymbol = tuple.symbol!
            currencyName = tuple.name!
        }
        amountPaidTextField.setInputAmountPaid(with: currencySymbol)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addKeyboardObservers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardObservers()
    }
    
    
    
    // MARK: -
    private func configureColors() {
        bottomView.backgroundColor = .whiteGrayDynColour
        view.backgroundColor = .whiteBlackDynColour
        
        let textColour = UIColor.formTextColour
        placeOfPurchaseTextField.textColor = textColour
        amountPaidTextField.textColor = textColour
        dateTextField.textColor = textColour
    }
    
    
    //MARK: - Keyboard
    
    private func addKeyboardObservers() {
        notificationCenter.addObserver(self, selector: #selector(keyboardAppearanceChanged), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardAppearanceChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardAppearanceChanged(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        bottomViewBottomConstraint.isActive = false
        let newConstatnt = (notification.name == UIResponder.keyboardWillShowNotification) ? (-keyboardRect.height + 110) : 0
        bottomViewBottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: newConstatnt)
        bottomViewBottomConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    //MARK: - Navigation Bar
    
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.navigationColour
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            topNavigationBar.standardAppearance = appearance
            topNavigationBar.scrollEdgeAppearance = appearance
            topNavigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        } else {
            topNavigationBar.barTintColor = UIColor.wetAsphalt
            topNavigationBar.tintColor = UIColor.white
            topNavigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    
    
    
    //MARK: - Gestures
    func setupGestures() {
        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.addGestureRecognizer(imageGesturesViewModel.createPinchGesture()) //Pinch Gesture
        receiptImageView.addGestureRecognizer(imageGesturesViewModel.createPanGesture()) //Pan Gesture
    }
    
    

    //MARK: - TextFields & Button
    
    func setTextFields() {
        placeOfPurchaseTextField.text = place
        dateTextField.text = date.toString(as: .long)
        
        if (paymentAction == .UpdatePayment) {
            amountPaidTextField.text = amountPaid.ToString(decimals: 2)
        }
    }
    
    func setupTextFields() {
        drawBottomLine(for: amountPaidTextField)
        drawBottomLine(for: placeOfPurchaseTextField)
        drawBottomLine(for: dateTextField)
    }
    
    /// Draws a line underneath the textfield
    func drawBottomLine(for textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 7, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.flatBlue.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    
    func setupAddButton() {
        addButton.backgroundColor = .flatOrange
        addButton.layer.cornerRadius = addButton.frame.size.height/4
        addButton.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 4, blur: 6)
        
        let buttonTitle = (paymentAction == .AddPayment) ? "Add" : "Update"
        addButton.setTitle( buttonTitle, for: .normal)
        
        buttonAnimations.startAnimatingPressActions(for: addButton)
    }
    
    
    
    
    //MARK: - Fields actions
    
    @IBAction func startedEditingAmountPaid(_ sender: UITextField) {
    }
    
    
    @IBAction func startedEditingPlace(_ sender: UITextField) {
    }
    
    
    @IBAction func startedEditingDate(_ sender: Any) {
    }
    
    
    @objc func pressedDoneDatePicker() {
        if let datePicker = self.dateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            self.dateTextField.text = dateformatter.string(from: datePicker.date)
            date = datePicker.date
        }
        self.dateTextField.resignFirstResponder()
    }
  
    
    
    
    //MARK: - Add Button actions
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        if successfullFieldValidation() == false {
            return
        }
        
        amountPaid = amountPaidTextField.text!.floatValue
        place = placeOfPurchaseTextField.text!
        
        let paymentInfo = PaymentInformation(amountPaid: amountPaid,
                                             place: place,
                                             date: date,
                                             receiptImage: receiptImageView.image ?? UIImage(),
                                             currencySymbol: currencySymbol,
                                             currencyName: currencyName)
        
        postNotification(action: paymentAction, info: paymentInfo)
        
        if (paymentAction == .AddPayment) {
            navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    private func postNotification(action: PaymentAction, info: PaymentInformation) {
        let userInfo: [NotificationUserInfo : Any] = [.action : action,
                                                      .info   : info]
        notificationCenter.post(name: .didReceivePaymentData, object: self, userInfo: userInfo)
    }

    
    
    private func successfullFieldValidation() -> Bool  {
        if textFieldsHaveValues() == false {
            Alert.shared.showEmptyFieldsAlert(for: self)
            return false
        }
        
        if priceOverflow() {
            Alert.shared.showPriceOverflow(for: self, currencySymbol: currencySymbol)
            return false
        }
        
        return true
    }
    
    
    private func priceOverflow() -> Bool {
        if amountPaidTextField.text!.floatValue < 0
            || amountPaidTextField.text!.floatValue > 1_000_000 {
            return true
        }
        
        return false
    }
    
    private func textFieldsHaveValues() -> Bool {
        if amountPaidTextField.text == "" { return false }
        if placeOfPurchaseTextField.text == "" { return false }
        return true
    }
    
    
    //MARK: - Bar Buttons Actions
    @IBAction func returnToCameraBarButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveToLibraryBarButtonPressed(_ sender: UIBarButtonItem) {
        Alert.shared.showSaveToLibAlert(for: self,
                                        image: receiptImageView.image!,
                                        savePhotoSelector: #selector(self.image(_:didFinishSavingWithError:contextInfo:)))
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        Alert.shared.showSaveSuccessStatusAlert(for: self, error: error)
    }
    
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        presentCropViewController(withImage: receiptImageView.image!)
    }
    
    
    @IBAction func deleteBarButtonPressed(_ sender: UIBarButtonItem) {
        Alert.shared.showRemoveAlert(for: self) { [unowned self] in
            if (self.paymentAction == .UpdatePayment) {
                let userInfo: [PaymentAction : UUID] = [self.paymentAction : self.paymentUID]
                self.notificationCenter.post(name: .removePayment, object: self, userInfo: userInfo)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    
    
    //MARK: - Text detection
    
    @IBAction func pressedDetectTextButton(_ sender: UIButton) {
        let textRecogniser = TextRecogniser()
        amountPaid = textRecogniser.findReceiptDetails(for: passedImage!)
        amountPaidTextField.text = "£\(amountPaid.ToString(decimals: 2))"
    }
    
}




//MARK: - CropViewController Pod implementation
extension PaymentViewController: CropViewControllerDelegate {
    
    func presentCropViewController(withImage image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }


    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let vc = cropViewController.children.first!
        vc.modalTransitionStyle = .coverVertical
        vc.presentingViewController?.dismiss(animated: true, completion: nil)
        
        receiptImageView.image = image
    }


    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        let vc = cropViewController.children.first!
        vc.modalTransitionStyle = .coverVertical
        vc.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
