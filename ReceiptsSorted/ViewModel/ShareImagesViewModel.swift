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
        
        createOperations()
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
    
    func createOperations() {
        guard let nameImagePair = createNameImageDataPair(for: passedPayments) else { return }
        
        let createDirecoryOp = DirectoryCreatorOperation(directoryName: "test", in: .documentDirectory)
        let addPhotosOp = AddPhotosOperation(for: nameImagePair)
        let zipDirectoryOp = ZipDirectoryOperation(zipName: "testcheck")
        
        addPhotosOp.addDependency(createDirecoryOp)
        zipDirectoryOp.addDependency(addPhotosOp)
        
//        createDirecoryOp.completionBlock = {
//            print("DEBUG: Created directory path - \(createDirecoryOp.directoryPath)")
//        }
//        addPhotosOp.completionBlock = {
//            print("DEBUG: add[hotos completed: \(addPhotosOp.photosURLs)")
//        }
//        zipDirectoryOp.completionBlock = {
//            print("DEBUG: Completed zipping: \(zipDirectoryOp.zipURL)")
//        }
        
        addPhotosOp.onPhotosAdded = { [weak self] photosURLs in
            guard let urls = photosURLs else { return }
            self?.photosURLs = urls
        }
        
        zipDirectoryOp.onZipCreated = { [weak self] url in
            self?.zipURL = url
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
