//
//  ImageCommands.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation

class ImageCommands {
    
    var mainView: ViewController!
    var imagePicker: UIImagePickerController!
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    
    func setupCustomCamera() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    
    func setupCaptureSession() {
        //Specify high-resolution photo quality
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if (device.position == AVCaptureDevice.Position.back) {
                backCamera = device
            } else if (device.position == AVCaptureDevice.Position.front) {
                frontCamera = device
            }
            
            currentCamera = backCamera
        }
    }
    
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        } catch {
            print(error)
        }
    }
    
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = mainView.view.frame
        mainView.view.layer.addSublayer(cameraPreviewLayer!)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    
    
    
    
    
    
    
    
    
    
    func handleAddButton() {
        getImage(using: .camera)
    }
    
    
    
    
    func getImage(using imageSource: ImageSource) {
        if (imageSource == .camera) {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                self.showAlertWith(title: "Camera is unavailable!", message: "You did not allow access to your camera or the camera is broken")
                return
            }
        } else {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                self.showAlertWith(title: "Photo Library is unavailable!", message: "You did not allow access to your photo library")
                return
            }
        }
                
        selectImageFrom(imageSource)
    }
    
    
    
    
    func selectImageFrom(_ source: ImageSource) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = mainView.self
        switch source {
            case .camera:
                imagePicker.sourceType = .camera
            case .photoLibrary:
                imagePicker.sourceType = .photoLibrary
        }
        mainView.imagePicker = imagePicker //set imagePicker for ViewController
        //mainView.present(imagePicker, animated: true, completion: nil)
        mainView.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - Show Payment ViewController
    
    func actionsOnFinishPickingMedia(imagePicker: UIImagePickerController, info: [UIImagePickerController.InfoKey : Any]) {

        imagePicker.dismiss(animated: false, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        showPaymentVC(withImage: selectedImage)
    }
       
       
    func showPaymentVC(withImage image: UIImage) {

        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.modalPresentationStyle = .fullScreen
            mainView.present(paymentVC, animated: false, completion: nil)
        }
    }
    
    
    
    
    
    //MARK: - Show Alert method
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        mainView.present(ac, animated: true)
    }
    
    
    
    
    
    
    
    
    
//    func saveImageToGallery() {
//        guard let selectedImage = mainView.imageTake.image else {
//                print("Image not found!")
//                showAlertWith(title: "No image selected!", message: "")
//                return
//            }
//
//            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
//    
//    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            showAlertWith(title: "Save error", message: error.localizedDescription)
//        } else {
//            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
//        }
//    }
    
}

