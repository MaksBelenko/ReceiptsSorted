//
//  Alerts.swift
//  ReceiptsSorted
//
//  Created by Maksim on 28/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class Alert {
    
    ///let constatnt in order to share alert
    static let shared = Alert()
    
    
    // MARK: - Email button alerts
    
    /**
     Shows an action sheet PDF or Photos selection is available
     - Parameter controller: ViewController that should present the alarm
     - Parameter payments: Payments that should be shown on the controller that will be selected to be shown
     - Parameter onComplete: Method that should be executed after chosen View Controller is chosen
     */
    func showFileFormatAlert(for controller: UIViewController, withPayments payments: [Payment], onComplete: (() -> ())? = nil) {
        let pdfAction = UIAlertAction(title: "PDF (Table & photos)", style: .default, handler: { _ in
            Navigation.shared.showPDFPreview(for: controller, withPayments: payments, onComplete: onComplete)
        })
        let archiveAction = UIAlertAction(title: "Photos only", style: .default, handler: { _ in
            Navigation.shared.showShareImagesVC(for: controller, withPayments: payments, onComplete: onComplete)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "Send receipts as:", message: nil , preferredStyle: .actionSheet),
                                 actions: [pdfAction, archiveAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    /**
     An alert to be shown when user tries to dismiss when no receipts are selected
     - Parameter controller: ViewController that should present the alarm
     */
    func showNoPaymentsErrorAlert(for controller: UIViewController) {
        Vibration.error.vibrate()
        let alert = AlertHelper(alertController: UIAlertController(title: "No receipts selected!", message: "Please select the receipts that you would like to send" , preferredStyle: .alert),
                                 actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
        alert.show(for: controller)
    }
    
    
    /**
     */
    func showDismissSelectionAlert(for controller: UIViewController, onDismissClicked: @escaping () -> ()) {
        Vibration.light.vibrate()
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: { _ in
            onDismissClicked()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "Do you want to cancel the operation?", message: nil , preferredStyle: .actionSheet),
                                actions: [dismissAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    // MARK: - PDF Alerts
    
    /**
     Action sheet that should be presented when trying to dismiss View Controller
     - Parameter controller: ViewController that should present the alarm
    */
    func showDismissPdfAlert(for controller: UIViewController) {
        Vibration.light.vibrate()
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "Are you sure you want to dismiss the pdf?", message: nil , preferredStyle: .actionSheet),
                                 actions: [dismissAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - Share Images Alerts
    
    /**
     Action sheet that shows options of sending Images or Zip archive
     - Parameter controller: ViewController that should present the alarm
     - Parameter onShareClicked: Method that will be executed when one of the options clicked
     */
    func showShareSelector(for controller: UIViewController, onShareClicked: @escaping (ShareImagesType) -> ()) {
        let photosAction = UIAlertAction(title: "Just images", style: .default, handler: { _ in
            onShareClicked(.RawImages)
        })
        let archiveAction = UIAlertAction(title: "Zip Archive", style: .default, handler: { _ in
            onShareClicked(.Zip)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "How do you want to send images?", message: nil , preferredStyle: .actionSheet),
                                 actions: [archiveAction, photosAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - Card Alerts
    
    /**
     Presents an action sheet checking weather removing was intended
     - Parameter controller: ViewController that should present the alarm
     - Parameter onDelete: Mthod that should be executed on delete confirmation
     */
    func showRemoveAlert(for controller: UIViewController, onDelete: @escaping () -> ()) {
        Vibration.light.vibrate()
        
        let deleteAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { _ in
            onDelete()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "Are you sure you want to delete the payment?", message: nil , preferredStyle: .actionSheet),
                                 actions: [deleteAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - Save Photo to library alert
    
    /**
     Show action sheet when trying to save to the photo library
     - Parameter controller: ViewController that should present the alarm
     - Parameter image: Image that is to be saved to library
     - Parameter savePhotoSelector: Selector to be executed on save
     */
    func showSaveToLibAlert(for controller: UIViewController, image: UIImage, savePhotoSelector: Selector) {
        let deleteAction = UIAlertAction(title: "Yes, save", style: .default, handler: { _ in
            UIImageWriteToSavedPhotosAlbum(image, controller, savePhotoSelector, nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertHelper(alertController: UIAlertController(title: "Do you want to save the receipt image to your photos?", message: nil , preferredStyle: .actionSheet),
                                 actions: [deleteAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    /**
     After a try of saving a photo to the library show if it is a success or fail
     - Parameter controller: ViewController that should present the alarm.
     - Parameter error: Error depending in which the message is created
     */
    func showSaveSuccessStatusAlert(for controller: UIViewController, error: Error?) {
        let ac: UIAlertController
        if let err = error {
            ac = UIAlertController(title: "Error saving an image", message: "Go to Settings -> WorkReceipts -> Photos -> Enable \"Add Photos Only\" in order to use this function", preferredStyle: .alert)
            Log.exception(message: "Failed to save the photo to Library. Error: \(err.localizedDescription)")
        } else {
            ac = UIAlertController(title: "Receipt image saved", message: "Your receipt image has been saved to your photos.", preferredStyle: .alert)
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        controller.present(ac, animated: true)
    }
    
    /**
     Shows an alert which indicates that some of the required dields are empty
     - Parameter controller: ViewController that should present the alarm.
     */
    func showEmptyFieldsAlert(for controller: UIViewController) {
        Vibration.error.vibrate()
        let alert = AlertHelper(alertController: UIAlertController(title: "Fill all data", message: "Some of the information is not filled", preferredStyle: .alert),
                                 actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
        alert.show(for: controller)
    }
    
    
    func showPriceOverflow(for controller: UIViewController, currencySymbol: String) {
        Vibration.error.vibrate()
        let alert = AlertHelper(alertController: UIAlertController(title: "Price too large", message: "Price in \(currencySymbol) should less than a 100k", preferredStyle: .alert),
                                 actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - SettingsVC Alerts
    
    func showImageCompressionInfo(for controller: UIViewController) {
        let text = """
                    It's necessary to save your device memory and send receipts faster.
                    Best - readable and minimal space required.
                    Decent – more clear pictures.
                    None – takes a lot of device’s memory.
                   """
        
        let ac = UIAlertController(title: "Image Compression", message: text, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        controller.present(ac, animated: true)
    }
    
    
    func showDateIndicator(for controller: UIViewController) {
        let text = """
                    Indicator presents either a week, with last day being friday, or a month,
                    with last day being last day of the month. Also, it sets notifications to
                    be sent on a last day of the period.
                   """
        
        let ac = UIAlertController(title: "Date Indicator", message: text, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        controller.present(ac, animated: true)
    }
    
    
    func showCurrencyChangeWarning(for controller: UIViewController) {
        let ac = UIAlertController(title: "Warning: currency change",
                                   message: "If you have receipts paid with different currency they will no longer be shown in the indicators. Only main currency payments sum are shown.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        controller.present(ac, animated: true)
    }
    
    
    // MARK: - Camera alerts
    
    func showCameraNotEnabledAlert(for controller: UIViewController) {
        let ac = UIAlertController(title: "Camera is not enabled",
                                   message: "You need to enable access to the camera in your device's settings if you want to it.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        controller.present(ac, animated: true)
    }
}
