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

    var pageType: ShowPaymentAs = .AddPayment
    
    var passedImage: UIImage? = nil
    var amountPaid: Float = 0.0
    var place: String = ""
    var date: Date = Date()
    
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var amountPaidTextField: UITextField!
    @IBOutlet weak var placeOfPurchaseTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    let buttonAnimations = AddButtonAnimations()
    var imageGesturesViewModel = ImageGesturesViewModel()
    
    weak var paymentDelegate: PaymentDelegate?
    
    
    
    
    
    //set Status Bar icons to black
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    
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
        
        amountPaidTextField.delegate = self
        placeOfPurchaseTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        addKeyboardObservers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardObservers()
    }
    
    
    
    
    
    //MARK: - Keyboard
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceChanged), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceChanged), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceChanged), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardAppearanceChanged(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if (notification.name == UIResponder.keyboardWillShowNotification ) {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
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
            appearance.backgroundColor = UIColor.wetAsphalt
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
        
        if (pageType == .UpdatePayment) {
            amountPaidTextField.text = "£" + amountPaid.ToString(decimals: 2)
            dateTextField.text = date.ToString(as: .long)
        }
        
        if (pageType == .AddPayment) {
            amountPaidTextField.text = "£0.00"
            dateTextField.text = date.ToString(as: .long)
        }
    }
    
    func setupTextFields() {
        drawBottomLine(for: amountPaidTextField)
        drawBottomLine(for: placeOfPurchaseTextField)
        drawBottomLine(for: dateTextField)
    }
    
    
    func drawBottomLine(for textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 7, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.wetAsphalt.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
    
    
    
    
    func setupAddButton() {
        addButton.layer.cornerRadius = addButton.frame.size.height/4
        addButton.layer.applyShadow(color: .flatOrange, alpha: 0.5, x: 1, y: 4, blur: 6)
        
        let buttonTitle = (pageType == .AddPayment) ? "Add" : "Save"
        addButton.setTitle( buttonTitle, for: .normal)
        
        buttonAnimations.startAnimatingPressActions(for: addButton)
    }
    
    
    
    
    //MARK: - Fields actions
    
    @IBAction func startedEditingAmountPaid(_ sender: UITextField) {
//        showTextPopup(popupType: .AmountPaid, numericText: amountPaidTextField.text ?? "")
    }
    
    
    @IBAction func startedEditingPlace(_ sender: UITextField) {
//        showTextPopup(popupType: .Place, numericText: placeOfPurchaseTextField.text ?? "")
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
        
        let paymentTuple = (amountPaid: amountPaid, place: place, date: date, receiptImage: receiptImageView.image ?? UIImage())
        paymentDelegate?.passData(as: pageType, paymentTuple: paymentTuple)
        
        if (pageType == .AddPayment) {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    //MARK: - Bar Buttons Actions
    @IBAction func returnToCameraBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveToLibraryBarButtonPressed(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: "Do you want to save the receipt image to your photos?", message: nil , preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Yes, save", style: .default, handler: { alert in
            guard let image = self.receiptImageView.image else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error saving an image", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Receipt image saved", message: "Your receipt image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        presentCropViewController(withImage: receiptImageView.image!)
    }
    
    
    @IBAction func deleteBarButtonPressed(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: "Are you sure you want to remove the payment?", message: nil , preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Yes, remove", style: .destructive, handler: { alert in
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - Text detection
    
    @IBAction func pressedDetectTextButton(_ sender: UIButton) {
        let textRecogniser = TextRecogniserViewModel()
        amountPaid = textRecogniser.findReceiptDetails(for: passedImage!)
        amountPaidTextField.text = "£\(amountPaid.ToString(decimals: 2))"
    }
    
}





//MARK:- PopupDelegate
extension PaymentViewController: PopupDelegate {
    
    func setAmountPaidValue(value: Float) {
        amountPaid = value
        amountPaidTextField.text = "£" + value.ToString(decimals: 2)
    }
    
    func setPlaceValue(value: String) {
        place = value
        placeOfPurchaseTextField.text = value
    }
    
    func setDatepopupValue(value: Date) {
        date = value
        dateTextField.text = value.ToString(as: .long)
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
        let viewController = cropViewController.children.first!
        viewController.modalTransitionStyle = .coverVertical
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        
        receiptImageView.image = image
    }


    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        let viewController = cropViewController.children.first!
        viewController.modalTransitionStyle = .coverVertical
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
