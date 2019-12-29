//
//  ImageCommands.swift
//  ReceiptsSorted
//
//  Created by Maksim on 26/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

class ImageCommands {
    
    var mainView: ViewController!
    var imagePicker: UIImagePickerController!
    
    
    
    func handleAddButton() {
        self.getImage(using: .camera)
        
//        let actionSheet = UIAlertController( title: nil, message: nil, preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default , handler:{ (UIAlertAction) in
//            print("User Take Photo button")
//            self.getImage(using: .camera)
//
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Choose from Gallery", style: .default , handler:{ (UIAlertAction) in
//            print("User Choose from Gallery button")
//            self.getImage(using: .photoLibrary)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
//            print("User click Cancel button")
//        }))
//
//        mainView.present(actionSheet, animated: true, completion: {
//            print("completion block")
//        })
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

