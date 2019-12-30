//
//  CameraViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    var controllerFrame: CGRect?
    
    var captureSession: AVCaptureSession?
//    var backCamera: AVCaptureDevice?
//    var frontCamera: AVCaptureDevice?
//    var currentCamera: AVCaptureDevice?
//
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = controllerFrame ?? CGRect(x: 0, y: 0, width: 100, height: 100)
        
        setupPreviewLayer()
        startRunningCaptureSession()
        
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.size.height/2
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    
    func startRunningCaptureSession() {
        captureSession!.startRunning()
    }
    
    
    
    
    func showPaymentVC(withImage image: UIImage) {
        
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.modalPresentationStyle = .fullScreen
            self.present(paymentVC, animated: false, completion: nil)
        }
    }

    
    
    
    @IBAction func pressedTakePhotoButton(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    @IBAction func pressedCloseCamera(_ sender: UIButton) {
        captureSession!.stopRunning()
        dismiss(animated: true, completion: nil)
    }
    

    
}




//MARK: - Extension for photo capture methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            
            captureSession!.stopRunning()
            
            showPaymentVC(withImage: image!)
            
        }
        
    }
}
