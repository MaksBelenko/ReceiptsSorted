//
//  ViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/12/2019.
//  Copyright © 2019 Maksim. All rights reserved.
//

import UIKit

enum ImageSource {
    case photoLibrary
    case camera
}

class ViewController: UIViewController, UINavigationControllerDelegate  {

    @IBOutlet var imageTake: UIImageView!
    
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var plusButton: UIButton!
    
    var imageCmd = ImageCommands()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCmd.mainView = self
        
        plusButton.layer.cornerRadius = plusButton.frame.height / 2
    }

    
    
    //MARK: - Select image from library
 
//    func selectImageFrom(_ source: ImageSource) {
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        switch source {
//            case .camera:
//                imagePicker.sourceType = .camera
//            case .photoLibrary:
//                imagePicker.sourceType = .photoLibrary
//        }
//        present(imagePicker, animated: true, completion: nil)
//    }
    
    
    
    
    //MARK: - Take a picture on camera
    @IBAction func addNewReceipt(_ sender: UIButton) {
   
        imageCmd.handleAddButton()
    }
    
    
//    func handleAddButton(my : ViewController) {
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
//        self.present(actionSheet, animated: true, completion: {
//            print("completion block")
//        })
//    }
    
    
    
//    func getImage(using imageSource: ImageSource) {
//        if (imageSource == .camera) {
//            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//                self.showAlertWith(title: "Camera is unavailable!", message: "You did not allow access to your camera or the camera is broken")
//                return
//            }
//        } else {
//            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
//                self.showAlertWith(title: "Photo Library is unavailable!", message: "You did not allow access to your photo library")
//                return
//            }
//        }
//
//        self.selectImageFrom(imageSource)
//    }
    
    
    //MARK: - Saving Image to Gallery

    @IBAction func saveImageToGallery(_ sender: UIButton) {
        
        //imageCmd.saveImageToGallery()
        
//        guard let selectedImage = imageTake.image else {
//                print("Image not found!")
//                showAlertWith(title: "No image selected!", message: "")
//                return
//            }
//
//            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    

//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            showAlertWith(title: "Save error", message: error.localizedDescription)
//        } else {
//            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
//        }
//    }

    
    
//    func showAlertWith(title: String, message: String){
//        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
//    }
 }








//MARK: - EXTENSION for ImagerPicker
 extension ViewController: UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
}


