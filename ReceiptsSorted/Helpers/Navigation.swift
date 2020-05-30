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
        cameraVC.cardVM = vc.cardViewController.cardViewModel
        
        vc.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    
    
    // MARK: - CardViewController
    func showPaymentVC(for controller: CardViewController, payment selectedPayment: Payments) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = UIImage(data: selectedPayment.receiptPhoto?.imageData ?? Data())
            Log.debug(message: "size in MB = \(Float((selectedPayment.receiptPhoto?.imageData?.count)!) / powf(10, 6))")
            
            paymentVC.amountPaid = selectedPayment.amountPaid
            paymentVC.place = selectedPayment.place!
            paymentVC.date = selectedPayment.date!
            paymentVC.pageType = .UpdatePayment
            
            paymentVC.paymentDelegate = controller.cardViewModel
            
            paymentVC.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(paymentVC, animated: true)
        } else {
            NSLog("Error showing PaymentViewController")
        }
    }
    
    
    func showPDFPreview(for controller: UIViewController, withPayments payments: [Payments]) {
        guard let cardVC = controller as? CardViewController else {
            NSLog("Controller requested cameraVC is not CardViewController")
            Log.exception(message: "Controller requested cameraVC is not CardViewController")
            return
        }
        
        let pdfPreviewVC = PDFPreviewViewController(nibName: "PDFPreviewViewController", bundle: nil)
        pdfPreviewVC.passedPayments = payments
        pdfPreviewVC.isModalInPresentation = true
        cardVC.present(pdfPreviewVC, animated: true) {
            cardVC.selectingPayments(mode: .Disable)
        }
    }
    
    
    func showArchivedImagesViewer(for controller: UIViewController, withPayments payments: [Payments]) {
        guard let cardVC = controller as? CardViewController else {
            NSLog("Controller requested cameraVC is not CardViewController")
            Log.exception(message: "Controller requested cameraVC is not CardViewController")
            return
        }
        
        let archiveVC = ShareImagesViewController()
        let navController = UINavigationController(rootViewController: archiveVC)
        archiveVC.passedPayments = payments
        navController.isModalInPresentation = true
        cardVC.present(navController, animated: true) {
            cardVC.selectingPayments(mode: .Disable)
        }
    }
    
    
    // MARK: - CameraViewController
    func showPaymentVC(for controller: CameraViewController, withImage image: UIImage) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.paymentDelegate = controller.cardVM
            paymentVC.modalPresentationStyle = .fullScreen
            controller.navigationController?.pushViewController(paymentVC, animated: true)
        }
    }
    
    
    
}
