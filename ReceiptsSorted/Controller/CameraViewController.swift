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
    @IBOutlet weak var cameraView: UIView!
    
    var controllerFrame: CGRect?
    var photoOutput: AVCapturePhotoOutput?
    var cameraSession: CameraSessionViewModel?
    var image: UIImage?
    let imagePicker = UIImagePickerController()
    
    var mainView: CardViewController?
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        self.view.frame = controllerFrame ?? CGRect(x: 0, y: 0, width: 100, height: 100)
        
        setupCameraSession()
        setupGestureRecognisers()
    }
        
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cameraSession!.startRunningCaptureSession()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    
        view.backgroundColor = .flatOrange
        cameraView.backgroundColor = .flatOrange
        
        cameraSession!.stopCaptureSession()
    }
    
    
    
    
    func setupCameraSession() {
        cameraView.layer.cornerRadius = 20
        cameraSession = CameraSessionViewModel(forView: cameraView)
        
        cameraSession?.changeBackgroundColor.bind { [unowned self] in
            if ($0 == true) {
                self.view.backgroundColor = UIColor.black
                self.cameraView.backgroundColor = UIColor.black
            }
        }
    }
    
    
    func setupGestureRecognisers() {
        // Create gesture recognisers for focusing of camera
        let tapGestureRecogniser = UITapGestureRecognizer(target: cameraSession, action: #selector(cameraSession?.handleTapToFocus(recogniser:)))
        cameraView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    
    
    
    
    
    
    func showPaymentVC(withImage image: UIImage) {
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
        //cameraSession!.stopCaptureSession()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func pressedFlashButton(_ sender: UIButton) {
       let picName = cameraSession?.nextFlashMode()
        sender.setBackgroundImage(UIImage(systemName: picName!), for: UIControl.State.normal)
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
            
            showPaymentVC(withImage: image!)
        }
        
    }
}
