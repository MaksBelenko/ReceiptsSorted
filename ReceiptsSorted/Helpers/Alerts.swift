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
        let archiveAction = UIAlertAction(title: "Archive (Only photos)", style: .default, handler: { alert in
            //TODO: Implement
            guard let controller = controller as? ViewController else { return }
            controller.showArchivedImagesViewer()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(pdfAction)
        optionMenu.addAction(archiveAction)
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
}
