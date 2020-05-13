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
    
    
    private lazy var cancelBarButton: UIBarButtonItem = {
        guard let closeImage = UIImage(systemName: "xmark") else { return UIBarButtonItem() }
        return UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(cancelButtonPressed))
    }()

    private lazy var shareBarButton: UIBarButtonItem = {
        guard let shareImage = UIImage(systemName: "square.and.arrow.up") else { return UIBarButtonItem() }
        return UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(shareButtonPressed))
    }()

    
    
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

    
    // MARK: - Configure UI
    
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
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    
    private func setupBarButtons() {
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = shareBarButton
    }
    
    
    
    
    // MARK: - Buttons actions
    
    @objc private func cancelButtonPressed() {
        Alert.shared.showDismissPdfAlert(for: self)
    }
    
    
    @objc private func shareButtonPressed() {
        guard let url = zipURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
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
        var namesDictionary = Dictionary<String, Int>()
        
        for payment in passedPayments {
            guard let receiptPhotoData = payment.receiptPhoto else { return }
            guard let placeName = payment.place else { return }
            
            if !namesDictionary.contains(where: {$0.key == placeName} ) {
                namesDictionary[placeName] = 0
            } else {
                namesDictionary[placeName]! += 1
            }
            
            let count = (namesDictionary[placeName] == 0) ? "" : "_\(namesDictionary[placeName]!)"
            let fileName = "\(placeName)\(count).jpg"//"Image\(photoCounter).jpg"
            
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
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
            let directoryURL = URL(fileURLWithPath: directoryPath)
            return try Zip.quickZipFiles([directoryURL], fileName: directoryName) // Zip
        } catch {
            print("Zip failed with error: \(error.localizedDescription)")
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
