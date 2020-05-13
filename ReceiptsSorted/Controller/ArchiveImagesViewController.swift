//
//  ArchiveImagesViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Zip

class ArchiveImagesViewController: UIViewController {

    var passedPayments: [Payments]!
    
    private let directoryName = "Receipts"
    private var zipURL: URL!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationController?.delegate = self
        
        self.title = "Archived Images Viewer"
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupNavigationBar()
        setupBarButtons()
        
        DispatchQueue.global(qos: .utility).async {
            let directoryPath = self.createDirectory()
            self.addPhotosToDirectory(withPath: directoryPath)
            self.zipURL = self.zipDirectory(withPath: directoryPath)
        }
    }

    
    
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.wetAsphalt
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        } else {
            navigationController?.navigationBar.barTintColor = UIColor.wetAsphalt
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    
    private func setupBarButtons() {
        navigationController?.navigationBar.tintColor = UIColor.white
        
        guard let closeImage = UIImage(systemName: "xmark") else { return }
        let cancelButton = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
        
        guard let shareImage = UIImage(systemName: "square.and.arrow.up") else { return }
        let shareButton = UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(shareButtonPressed))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    
    
    
    
    @objc private func cancelButtonPressed() {
        Alert.shared.showDismissPdfAlert(for: self)
    }
    
    @objc private func shareButtonPressed() {
        
        guard let url = zipURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
//            if completed {
//                self.dismiss(animated: true, completion: nil)// User completed activity
//            }
//        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Helpers
    
    private func createDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let directoryURL = docURL.appendingPathComponent(directoryName)
        
        if FileManager.default.fileExists(atPath: directoryURL.absoluteString) {
            do {
                print("Removing directory \(directoryURL.path)")
                try FileManager.default.removeItem(atPath: directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // Create the directory again
        do {
            print("Creating directory in \(directoryURL.path)")
            try FileManager.default.createDirectory(atPath: directoryURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        
        return directoryURL.path
    }
    
    
    private func addPhotosToDirectory(withPath path: String) {
        var photoCounter = 1
        for payment in passedPayments {
            guard let receiptPhotoData = payment.receiptPhoto else { return }
            //            guard let date = payment.date else { return }
            //
            //            let image = UIImage(data: receiptPhotoData)
            let fileName = "Image\(photoCounter).jpg"
            photoCounter += 1
            
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)//dataPath.appendingPathComponent(fileName)
            print("FileURL = \(fileURL.path)")
            
            do {
                try receiptPhotoData.write(to: fileURL)  // writes the image data to disk
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
    private func zipDirectory(withPath directoryPath: String) -> URL? {
        do {
            let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let directoryURL = URL(fileURLWithPath: directoryPath)
            
            return try Zip.quickZipFiles([directoryURL], fileName: directoryName) // Zip
            //            print("zipFilePath = \(zipFileURL.path)")
        }
        catch {
            print("Something went wrong")
            return nil
        }
    }
}




// MARK: - UIAdaptivePresentationControllerDelegate
extension ArchiveImagesViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        Alert.shared.showDismissPdfAlert(for: self)
    }
}
