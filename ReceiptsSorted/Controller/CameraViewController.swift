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

    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        setupButton(withSize: 100)
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
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.addSublayer(cameraPreviewLayer!)
    }
    
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    
    
    
    
    func setupButton(withSize buttonSize: CGFloat) {
        let addButton = UIButton(type: .system)
        
        let buttonPositionX = self.view.frame.size.width/2 - buttonSize/2
        let buttonPositionY = self.view.frame.size.height/2
        addButton.frame = CGRect(x: buttonPositionX, y: buttonPositionY, width: buttonSize, height: buttonSize)
        addButton.backgroundColor = UIColor(rgb: 0xEDB200)
        
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 70)
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        addButton.setTitleColor(.white, for: .normal)
        
        addButton.addTarget(self, action: #selector(ViewController.handleAddButton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(addButton)
        
        addButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
        addButton.layer.cornerRadius = buttonSize/2
        
    }
    
    @objc func handleAddButton () {
        showPaymentVC(withImage: UIImage())
        //dismiss(animated: true, completion: nil)
    }
    
    func showPaymentVC(withImage image: UIImage) {

        if let paymentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetails") as? PaymentViewController
        {
            paymentVC.passedImage = image
            paymentVC.modalPresentationStyle = .fullScreen
            self.present(paymentVC, animated: false, completion: nil)
        }
    }

}
