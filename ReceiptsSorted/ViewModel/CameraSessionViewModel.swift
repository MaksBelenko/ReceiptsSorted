//
//  cameraSession.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit
import AVFoundation


class CameraSessionViewModel  {
    
    //MARK: - Fields
    private lazy var captureSession = AVCaptureSession()
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer? 
    
    private var view: UIView
    
    enum FlashMode {
        case Auto, Flash, NoFlash
    }
    var currentFlashMode = FlashMode.Auto
    
    
    
    //MARK: - Initialiser
    init(forView view: UIView) {
        self.view = view
        if (ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == nil) {
            setupCamera()
        }
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
        if (ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == nil) {
            DispatchQueue.global(qos: .userInteractive).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    /**
     Stop configured Capture Session.
     */
    func stopCaptureSession() {
        if (ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == nil) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
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
        if (ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == nil) {
            photoOutput?.capturePhoto(with: createPhotoSettings(), delegate: delegate)
        }
    }
    
    
    /**
     Creates AVCapturePhotoSettings for current Flash mode
     */
    private func createPhotoSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        
        if (currentFlashMode == .Auto) {
            settings.flashMode = AVCaptureDevice.FlashMode.auto
        }
        if (currentFlashMode == .Flash) {
            settings.flashMode = AVCaptureDevice.FlashMode.on
        }
        if (currentFlashMode == .NoFlash) {
            settings.flashMode = AVCaptureDevice.FlashMode.off
        }
        
        return settings
    }
    
    
    /**
     Sets next mode for Flash (Auto, Flash, NoFlash) when picture is taken
     and returns an image name to be shown as background of "flash" button
     */
    func nextFlashMode() -> String {
        if (currentFlashMode == .Auto) {
            currentFlashMode = .Flash
            return "bolt.fill"
        }
        if (currentFlashMode == .Flash) {
            currentFlashMode = .NoFlash
            return "bolt.slash.fill"
        }
        if (currentFlashMode == .NoFlash) {
            currentFlashMode = .Auto
            return "bolt.badge.a.fill"
        }
        return "exclamationmark.triangle.fill"
    }
}
