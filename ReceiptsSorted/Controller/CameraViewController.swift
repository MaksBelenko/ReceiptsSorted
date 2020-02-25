//
//  CameraViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    
    var controllerFrame: CGRect?
    var photoOutput: AVCapturePhotoOutput?
    var cameraSession: CameraSession?
    var image: UIImage?
    let imagePicker = UIImagePickerController()
    
    var mainView: ViewController?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        self.view.frame = controllerFrame ?? CGRect(x: 0, y: 0, width: 100, height: 100)
        
        cameraSession = CameraSession(forView: view)
        cameraSession!.startRunningCaptureSession()
        
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.size.height/2
    }
    
    
    
    
    
    func showPaymentVC(withImage image: UIImage) {
        
        //let imageManipulator = ImageManipulator()
        //let newImage = imageManipulator.croppedInRect(image: image)

        cameraSession!.stopCaptureSession()
        
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.paymentDelegate = mainView
            paymentVC.modalPresentationStyle = .fullScreen
            self.present(paymentVC, animated: true, completion: nil)
        }
    }

    
    
    
    //MARK: - Buttons actions
    @IBAction func pressedTakePhotoButton(_ sender: UIButton) {
        cameraSession?.setCapturePhoto(delegate: self)
    }
    
    
    @IBAction func pressedCloseCamera(_ sender: UIButton) {
        //Stop camera session
        cameraSession!.stopCaptureSession()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - Choosing picture from gallery
    @IBAction func pressedPickFromGalleryButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            showPaymentVC(withImage: pickedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}




//MARK: - Extension for photo capture methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation() {
            image = UIImage(data: imageData)
            //Stop camera seesion
            cameraSession!.stopCaptureSession()
            showPaymentVC(withImage: image!)
        }
        
    }
}
