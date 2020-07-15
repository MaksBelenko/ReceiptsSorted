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
    
    func showFileFormatAlert(for controller: UIViewController, withPayments payments: [Payment], onComplete: (() -> ())? = nil) {
        let pdfAction = UIAlertAction(title: "PDF (Table & photos)", style: .default, handler: { _ in
            Navigation.shared.showPDFPreview(for: controller, withPayments: payments, onComplete: onComplete)
        })
        let archiveAction = UIAlertAction(title: "Photos only", style: .default, handler: { _ in
            Navigation.shared.showShareImagesVC(for: controller, withPayments: payments, onComplete: onComplete)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertFactory(alertController: UIAlertController(title: "Send receipts as:", message: nil , preferredStyle: .actionSheet),
                                 actions: [pdfAction, archiveAction, cancelAction])
        alert.show(for: controller)
    }
    
    func showNoPaymentsErrorAlert(for controller: UIViewController) {
        Vibration.error.vibrate()
        let alert = AlertFactory(alertController: UIAlertController(title: "No receipts selected!", message: "Please select the receipts that you would like to send" , preferredStyle: .alert),
                                 actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - PDF Alerts
    
    /// Dismiss alert for PDFPreviewVC
    func showDismissPdfAlert(for controller: UIViewController) {
        Vibration.light.vibrate()
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: { _ in
            controller.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertFactory(alertController: UIAlertController(title: "Are you sure you want to dismiss the pdf?", message: nil , preferredStyle: .actionSheet),
                                 actions: [dismissAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    // MARK: - Share Images Alerts
    
    func showShareSelector(for controller: UIViewController, onShareClicked: @escaping (ShareImagesType) -> ()) {
        let photosAction = UIAlertAction(title: "Just images", style: .default, handler: { _ in
            onShareClicked(.RawImages)
        })
        let archiveAction = UIAlertAction(title: "Zip Archive", style: .default, handler: { _ in
            onShareClicked(.Zip)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertFactory(alertController: UIAlertController(title: "How do you want to send images?", message: nil , preferredStyle: .actionSheet),
                                 actions: [archiveAction, photosAction, cancelAction])
        alert.show(for: controller)
    }
    
    
    
    // MARK: - Card Alerts
    
    func removePaymentAlert(for controller: UIViewController, onDelete: @escaping () -> ()) {
        Vibration.light.vibrate()
        
        let deleteAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { _ in
            onDelete()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = AlertFactory(alertController: UIAlertController(title: "Are you sure you want to delete the payment?", message: nil , preferredStyle: .actionSheet),
                                 actions: [deleteAction, cancelAction])
        alert.show(for: controller)
    }
}
