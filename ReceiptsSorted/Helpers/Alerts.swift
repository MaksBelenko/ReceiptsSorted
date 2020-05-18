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
    
    func showEmailOptionAlert(for controller: UIViewController) {
        let optionMenu = UIAlertController(title: "Send:", message: nil , preferredStyle: .actionSheet)

        let allPendingAction = UIAlertAction(title: "All pending", style: .default, handler: { alert in
            self.showFileFormatAlert(for: controller)
        })
        let selecteReceiptsAction = UIAlertAction(title: "Select receipts", style: .default, handler: { alert in
            //TODO: Implement expantion and selection
            guard let controller = controller as? ViewController else { return }
            controller.cardViewController.isSelectionEnabled = true
            controller.cardViewController.tblView.reloadData()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(allPendingAction)
        optionMenu.addAction(selecteReceiptsAction)
        optionMenu.addAction(cancelAction)
        controller.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    func showFileFormatAlert(for controller: UIViewController) {
        let optionMenu = UIAlertController(title: "Send receipts as:", message: nil , preferredStyle: .actionSheet)

        let pdfAction = UIAlertAction(title: "PDF (Table & photos)", style: .default, handler: { alert in
            guard let controller = controller as? ViewController else { return }
            controller.showPDFPreview()
        })
        let archiveAction = UIAlertAction(title: "Photos only", style: .default, handler: { alert in
            guard let controller = controller as? ViewController else { return }
            controller.showArchivedImagesViewer()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(archiveAction)
        optionMenu.addAction(pdfAction)
        optionMenu.addAction(cancelAction)
        controller.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - PDF Alerts
    
    /// Dismiss alert for PDFPreviewVC
    func showDismissPdfAlert(for controller: UIViewController) {
        Vibration.light.vibrate()
        
        let optionMenu = UIAlertController(title: "Are you sure you want to dismiss the pdf?", message: nil , preferredStyle: .actionSheet)

        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: { alert in
            controller.dismiss(animated: true, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(dismissAction)
        optionMenu.addAction(cancelAction)
        controller.present(optionMenu, animated: true, completion: nil)
    }
    
    
    // MARK: - Share Images Alerts
    
    func showShareSelector(for controller: UIViewController) {
        let optionMenu = UIAlertController(title: "How do you want to send images?", message: nil , preferredStyle: .actionSheet)

        let photosAction = UIAlertAction(title: "Just images", style: .default, handler: { alert in
            guard let controller = controller as? ShareImagesViewController else { return }
            controller.showActivityVC(for: .RawImages)
        })
        
        let archiveAction = UIAlertAction(title: "Zip Archive", style: .default, handler: { alert in
            guard let controller = controller as? ShareImagesViewController else { return }
            controller.showActivityVC(for: .Zip)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(archiveAction)
        optionMenu.addAction(photosAction)
        optionMenu.addAction(cancelAction)
        controller.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Card Alerts
    
    func removePaymentAlert(for controller: UIViewController, payment: Payments, indexPath: IndexPath) {
        Vibration.light.vibrate()
        
        let optionMenu = UIAlertController(title: "Are you sure you want to delete the payment?", message: nil , preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Yes, delete", style: .destructive, handler: { _ in
            guard let controller = controller as? CardViewController else { return }
            controller.deletePayment(payment: payment, indexPath: indexPath)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        controller.present(optionMenu, animated: true, completion: nil)
    }
}
