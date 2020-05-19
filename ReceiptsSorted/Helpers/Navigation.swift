//
//  Navigation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 19/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class Navigation {
 
    ///let constatnt in order to share alert
    static let shared = Navigation()
    
    
    // MARK: - ViewController
    func showCameraVC(for controller: UIViewController) {
        guard let vc = controller as? ViewController else {
            NSLog("Controller requested cameraVC is not ViewController")
            return
        }
        
        let cameraVC = CameraViewController(nibName: "CameraViewController", bundle: nil)
        cameraVC.transitioningDelegate = vc
        cameraVC.modalPresentationStyle = .custom
        cameraVC.controllerFrame = vc.view.frame
        cameraVC.cardVC = vc.cardViewController
        
        vc.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    func showPDFPreview(for controller: UIViewController) {
        guard let vc = controller as? ViewController else {
            NSLog("Controller requested cameraVC is not ViewController")
            return
        }
        
        let payments = vc.cardViewController.database.fetchSortedData(by: .NewestDateAdded, and: .Pending)
        let pdfPreviewVC = PDFPreviewViewController(nibName: "PDFPreviewViewController", bundle: nil)
        pdfPreviewVC.passedPayments = payments
        pdfPreviewVC.isModalInPresentation = true
//        pdfPreviewVC.modalPresentationStyle = .overFullScreen
        vc.present(pdfPreviewVC, animated: true)
    }
    
    
    func showArchivedImagesViewer(for controller: UIViewController) {
        guard let vc = controller as? ViewController else {
            NSLog("Controller requested cameraVC is not ViewController")
            return
        }
        
        let payments = vc.cardViewController.database.fetchSortedData(by: .NewestDateAdded, and: .Pending)
        let archiveVC = ShareImagesViewController()
        let navController = UINavigationController(rootViewController: archiveVC)
        archiveVC.passedPayments = payments
        navController.isModalInPresentation = true
        vc.present(navController, animated: true)
    }
    
    
    
    
    // MARK: - CardViewController
    func showPaymentVC(for controller: UIViewController, payment selectedPayment: Payments) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = UIImage(data: selectedPayment.receiptPhoto?.imageData ?? Data())
            Log.debug(message: "size in MB = \(Float((selectedPayment.receiptPhoto?.imageData?.count)!) / powf(10, 6))")
            
            paymentVC.amountPaid = selectedPayment.amountPaid
            paymentVC.place = selectedPayment.place!
            paymentVC.date = selectedPayment.date!
            paymentVC.pageType = .UpdatePayment
            
            if let cardVC = controller as? CardViewController {
                paymentVC.paymentDelegate = cardVC
            }
            
            paymentVC.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(paymentVC, animated: true)
        } else {
            NSLog("Error showing PaymentViewControllersss")
        }
    }
    
    
    
}
