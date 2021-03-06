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
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var imagePickerButton: UIButton!
    
    
    var controllerFrame: CGRect?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraSession: CameraSession?
    private let imagePicker = UIImagePickerController()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    // MARK: - Deinit
    deinit {
        #if DEBUG
            print("DEBUG: CameraViewController deinit")
        #endif
    }
    
    
    // MARK: - Initialisation
    init() {
        super.init(nibName: "CameraViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.view.frame = controllerFrame ?? CGRect(x: 0, y: 0, width: 100, height: 100)
        setupCameraSession()
        setupGestureRecognisers()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraSession!.startRunningCaptureSession()
        animateButtons(open: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animateButtons(open: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraSession!.stopCaptureSession()
    }
    
    
    // MARK: - Setup
    
    func setupCameraSession() {
        cameraView.layer.cornerRadius = 20
        cameraSession = CameraSession(forView: cameraView) { error in
            Alert.shared.showCameraNotEnabledAlert(for: self)
        }
    }
    
    func setupGestureRecognisers() {
        // Create gesture recognisers for camera focusing
        let tapGestureRecogniser = UITapGestureRecognizer(target: cameraSession, action: #selector(cameraSession?.handleTapToFocus(recogniser:)))
        cameraView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    
    
    // MARK: - Opening animations
    private func animateButtons(open: Bool) {
        animate(view: takePhotoButton, open: open)
        animate(view: flashButton, open: open)
        animate(view: closeButton, open: open)
        animate(view: imagePickerButton, open: open)
    }
    
    private func animate(view: UIView, open: Bool) {
        view.transform = (open) ? CGAffineTransform.identity.translatedBy(x: 0, y: 50) : CGAffineTransform.identity
        view.alpha = (open) ? 0 : 1
        UIView.animate(withDuration: (open) ? 0.5 : 0.3) {
            view.transform = (open) ? CGAffineTransform.identity : CGAffineTransform.identity.translatedBy(x: 0, y: 50)
            view.alpha = (open) ? 1 : 0
        }
    }
    
    
    
    //MARK: - Buttons actions
    @IBAction func pressedTakePhotoButton(_ sender: UIButton) {
        takePictureAnimation()
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
            Navigation.shared.showPaymentVC(for: self, withImage: pickedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Extension for photo capture methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else {
                Log.exception(message: "Couldn't create image from data")
                return
        }
        
        Navigation.shared.showPaymentVC(for: self, withImage: image)
        
    }
}

// MARK: - Picture taking
extension CameraViewController {
    
    private func takePictureAnimation() {
        let flashView = UIView()
        flashView.frame = cameraView.frame
        flashView.frame.origin = CGPoint(x: 0, y: 0)
        flashView.backgroundColor = .white
        cameraView.addSubview(flashView)
        
        UIView.animate(withDuration: 0.5, animations: {
            flashView.alpha = 0
        }) { _ in
            flashView.removeFromSuperview()
        }
    }
}
