//
//  ShareImagesViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 12/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIActivityViewController

class ShareImagesViewModel {
    
    private var passedPayments: [Payment] = []
    private let directoryName = "Receipts"
    private let photoFormat = "jpg"
    private var zipURL: URL!
    private var photosURLs = [URL]()
    
    private let zipAdapter = ZipAdapter()
    
    
    private let operationQueue = OperationQueue()
    private var operations: [Operation] = []
    
    
    
    // MARK: - Initialisation
    init(payments: [Payment]) {
        passedPayments = payments
        
        createOperations()
    }
    
    deinit {
        print("DEBUG: ShareImagesViewModel deinit")
    }
    
    
    
    private func createOperations() {
        let createDirecoryOp = DirectoryCreatorOperation(directoryName: "test", in: .documentDirectory)
        
        createDirecoryOp.completionBlock = {
            print("DEBUG: Created directory path - \(createDirecoryOp.directoryPath)")
        }
        
        operationQueue.addOperation(createDirecoryOp)
        
        if operations.isEmpty == false {
            operations.forEach { $0.cancel() }
        }
        
        operations = [createDirecoryOp]
    }
    
    
    
    // MARK: - Public Methods
    
    /**
     Create Zip archive in Documents directory
     */
    func createZipArchive() {
        let directoryPath = DirectoryCreator().createDirectory(named: directoryName, in: .documentDirectory)
        addPhotosToDirectory(withPath: directoryPath)
        zipURL = zipDirectory(withPath: directoryPath)
    }
    
    /**
     Creates and Activity View Controller
     - Parameter shareType: Sharing source type (Images or Zip)
     - Returns: Controller with either Images or Zip as activity items
     */
    func createActivityVC(for shareType: ShareImagesType) -> UIActivityViewController? {
        let activityVC: UIActivityViewController
        
        switch shareType {
        case .RawImages:
            activityVC = UIActivityViewController(activityItems: photosURLs, applicationActivities: nil)
        case .Zip:
            guard let url = zipURL else { return nil }
            activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        
        return activityVC
    }
    
    
    // MARK: - Private methods
    

    
    /**
     Adds photos to directory and name them
     - Parameter path: Path to the directory where photos should be added
     */
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
            let fileName = "\(placeName)\(count).\(photoFormat)"//"Image\(photoCounter).jpg"
            
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
            photosURLs.append(fileURL)
            
            do {
                guard let imageData = receiptPhotoData.imageData else { fatalError("No ImageData to write to directory") }
                try imageData.write(to: fileURL)  // writes the image data to disk
//                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
    
    /**
     Archives the directory
     - Parameter directoryPath: path which directory should be archived
     - Returns: URL of the archive
     */
    private func zipDirectory(withPath directoryPath: String) -> URL? {
        do {
            let directoryURL = URL(fileURLWithPath: directoryPath)
            return try zipAdapter.zipFiles([directoryURL], fileName: directoryName)
        } catch {
            print("Zip failed with error: \(error.localizedDescription)")
            return nil
        }
    }
}
