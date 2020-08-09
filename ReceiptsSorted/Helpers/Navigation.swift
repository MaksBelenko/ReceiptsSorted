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
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .custom
        cameraVC.controllerFrame = controller.view.frame
        controller.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    
    
    // MARK: - CardViewController
    
    func showPDFPreview(for controller: UIViewController, withPayments payments: [Payment], onComplete: (() -> ())? = nil) {
        let pdfPreviewVC = PDFPreviewViewController()
        pdfPreviewVC.passedPayments = payments
        pdfPreviewVC.isModalInPresentation = true
        controller.present(pdfPreviewVC, animated: true) {
            guard let complete = onComplete else { return }
            complete()
        }
    }
    
    
    func showShareImagesVC(for controller: UIViewController, withPayments payments: [Payment], onComplete: (() -> ())? = nil) {
        let archiveVC = ShareImagesViewController()
        let navController = UINavigationController(rootViewController: archiveVC)
        archiveVC.passedPayments = payments
        navController.isModalInPresentation = true
        controller.present(navController, animated: true) {
            guard let complete = onComplete else { return }
            complete()
        }
    }
    
    
    // MARK: - CameraViewController
    func showPaymentVC(for controller: CameraViewController, withImage image: UIImage) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(paymentVC, animated: true)
        }
    }
    
    
    func showPaymentVC(for controller: CardViewController, payment selectedPayment: Payment) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = UIImage(data: selectedPayment.receiptPhoto?.imageData ?? Data())
            Log.debug(message: "size in MB = \(Float((selectedPayment.receiptPhoto?.imageData?.count)!) / powf(10, 6))")
            
            paymentVC.amountPaid = selectedPayment.amountPaid
            paymentVC.place = selectedPayment.place!
            paymentVC.date = selectedPayment.date!
            paymentVC.currencySymbol = selectedPayment.currencySymbol!
            paymentVC.currencyName = selectedPayment.currencyName!
            paymentVC.paymentAction = .UpdatePayment
            
            paymentVC.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(paymentVC, animated: true)
        } else {
            NSLog("Error showing PaymentViewController")
        }
    }
    
    
}
