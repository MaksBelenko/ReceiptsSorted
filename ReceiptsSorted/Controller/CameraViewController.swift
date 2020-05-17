//
//  CameraViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    var controllerFrame: CGRect?
    var photoOutput: AVCapturePhotoOutput?
    var cameraSession: CameraSession?
    let imagePicker = UIImagePickerController()
    
    
    private let circularTransition = CircularTransition()
    var cardVC: CardViewController?
    var addButtonCenter: CGPoint?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    //MARK: - Lifecycle
    
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
        navigationController?.delegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)        
        cameraSession!.stopCaptureSession()
        navigationController?.delegate = nil
    }
    
    
    // MARK: - Setup
    
    func setupCameraSession() {
        cameraView.layer.cornerRadius = 20
        cameraSession = CameraSession(forView: cameraView)
    }
    
    
    
    func setupGestureRecognisers() {
        // Create gesture recognisers for focusing of camera
        let tapGestureRecogniser = UITapGestureRecognizer(target: cameraSession, action: #selector(cameraSession?.handleTapToFocus(recogniser:)))
        cameraView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    
    
    // MARK: - Show PaymentVC
    
    func showPaymentVC(withImage image: UIImage) {
        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.paymentDelegate = cardVC
            paymentVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(paymentVC, animated: true)
        }
    }

    
    
    //MARK: - Buttons actions
    @IBAction func pressedTakePhotoButton(_ sender: UIButton) {
        cameraSession?.setCapturePhoto(delegate: self)
    }
    
    
    @IBAction func pressedCloseCamera(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
}


// MARK: - UIImagePickerControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate {
    
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
            guard let image = UIImage(data: imageData) else {
                Log.exception(message: "Couldn't create image from data")
                return
            }
            showPaymentVC(withImage: image)
        }
    }
}



// MARK: - UIViewControllerTransitioningDelegate
extension CameraViewController: UIViewControllerTransitioningDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        // Perform custom animation only if CameraViewController
        guard toVC is ViewController else { return nil }
        guard let center = addButtonCenter else { return nil }

        if operation == .pop {
            circularTransition.transitionMode = .pop
            circularTransition.startingPoint = center
            return circularTransition
        }

        return nil
    }
}
