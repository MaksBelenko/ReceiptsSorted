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
    private var zipURL: URL?
    private var photosURLs: [URL] = []
    
    private let zipAdapter = ZipAdapter()
    
    
    private let operationQueue = OperationQueue()
    private var operations: [Operation] = []
    
    
    
    // MARK: - Initialisation
    init(payments: [Payment]) {
        passedPayments = payments
    }
    
    deinit {
        print("DEBUG: ShareImagesViewModel deinit")
    }
    
    
    
    // MARK: - Activity VC Methods
    
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
    
    
    // MARK: - Operations
    
    func startPhotosZipOperations() {
        guard let nameImagePair = createNameImageDataPair(for: passedPayments) else { return }
        
        let createDirecoryOp = DirectoryCreatorOperation(directoryName: "Receipts", in: .documentDirectory)
        let addPhotosOp = AddPhotosOperation(for: nameImagePair)
        let zipDirectoryOp = ZipDirectoryOperation(zipName: "Receipts(\(Date().toString(as: .medium)))")
        
        addPhotosOp.addDependency(createDirecoryOp)
        zipDirectoryOp.addDependency(addPhotosOp)
        
//        createDirecoryOp.completionBlock = {
//            print("DEBUG: Created directory path - \(createDirecoryOp.directoryPath)")
//        }
        addPhotosOp.completionBlock = {
            DispatchQueue.main.async { [unowned self] in
                self.photosURLs = addPhotosOp.photosURLs
            }
        }
        zipDirectoryOp.completionBlock = {
            DispatchQueue.main.async { [unowned self] in
                self.zipURL = zipDirectoryOp.zipURL
            }
        }
        
        
        operationQueue.addOperation(createDirecoryOp)
        operationQueue.addOperation(addPhotosOp)
        operationQueue.addOperation(zipDirectoryOp)
        
//        if operations.isEmpty == false {
//            operations.forEach { $0.cancel() }
//        }
//
//        operations = [createDirecoryOp, addPhotosOp, zipDirectoryOp]
    }
    
    
    func cancelAllOperations() {
        operationQueue.cancelAllOperations()
    }
    
    
    
    // MARK: - Helper methods
    
    private func createNameImageDataPair(for payments: [Payment]) -> [(name: String, imageData: Data)]? {
        var pair: [(name: String, imageData: Data)] = []
        var namesDictionary = Dictionary<String, Int>()
        
        for payment in payments {
            guard let placeName = payment.place else { return nil }
            
            if !namesDictionary.contains(where: {$0.key == placeName} ) {
                namesDictionary[placeName] = 0
            } else {
                namesDictionary[placeName]! += 1
            }
            
            let count = (namesDictionary[placeName] == 0) ? "" : "_\(namesDictionary[placeName]!)"
            let fileName = "\(placeName)\(count).\(photoFormat)"//"Image\(photoCounter).jpg"
            
            
            guard let receiptPhotoData = payment.receiptPhoto,
                let imageData = receiptPhotoData.imageData else { return nil }
            
            pair.append( (name: fileName, imageData: imageData) )
        }
        
        return (pair.isEmpty) ? nil : pair
    }
}
