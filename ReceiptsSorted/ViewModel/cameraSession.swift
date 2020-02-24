//
//  cameraSession.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation


class CameraSession  {
    
    //MARK: - Fields
    private var captureSession = AVCaptureSession()
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer? 
    
    private var view: UIView
    
    
    
    
    //MARK: - Initialiser
    init(forView view: UIView) {
        self.view = view
        setupCamera()
    }
    
    
    //MARK: - Private methods
    private func setupCamera() {
        self.setupCaptureSession()
        self.setupDevice()
        self.setupInputOutput()
        self.setupPreviewLayer()
        self.setupLayersCaptureSession()
    }
    
    
    /**
     Sets AVCaptureSession for capture settings suitable for high-resolution photo quality output.
     */
    private func setupCaptureSession() {
        //Specify high-resolution photo quality
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    /**
     Sets camera for back camera with device type builtInWideAngleCamera.
     */
    private func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if (device.position == AVCaptureDevice.Position.back) {
                backCamera = device
            } else if (device.position == AVCaptureDevice.Position.front) {
                frontCamera = device
            }
        }
        
        currentCamera = backCamera
    }
    
    
    /**
     Sets Input as back camera and Output as photo in jpeg.
     */
    private func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    
    private func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    }
    
    private func setupLayersCaptureSession() {
        self.cameraPreviewLayer?.frame = view.frame
        view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    
    
    //MARK: - Public methods
    /**
     Starts configured Capture Session.
     */
    func startRunningCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    /**
     Stop configured Capture Session.
     */
    func stopCaptureSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.stopRunning()
        }
    }
    
    /**
     Sets delegate for capturing photo.
     - Parameter delegate: A delegate object to receive messages about capture
                           progress and results. The photo output calls your
                           delegate methods as the photo advances from capture
                           to processing to delivery of finished images.
     */
    func setCapturePhoto (delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: delegate)
    }
}
