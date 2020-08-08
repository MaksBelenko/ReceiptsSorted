//
//  ZipDirectoryOperation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 08/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

final class ZipDirectoryOperation: AsyncOperation {
    
    var zipURL: URL?
    var onZipCreated: ((URL?) -> ())?
    
    private let passedPath: String?
    private let zipName: String
    private let zipAdapter = ZipAdapter()
    
    
    init(zipName: String, directoryPath: String? = nil) {
        self.zipName = zipName
        passedPath = directoryPath
    }
    
    //    override func cancel() {
    //        super.cancel()
    //    }
    
    
    override func main() {
        defer { self.state = .finished }
        
        let dependencyPath = dependencies
                                .compactMap { ($0 as? UrlPathProvider)?.directoryPath }
                                .first
        
        guard let directoryPath = passedPath ?? dependencyPath else { return }
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
        do {
            let directoryURL = URL(fileURLWithPath: directoryPath)
            zipURL = try zipAdapter.zipFiles([directoryURL], fileName: zipName)
        } catch {
            print("Zip failed with error: \(error.localizedDescription)")
        }
        
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        if let onZipCreated = onZipCreated {
            DispatchQueue.main.async { [weak self] in
                onZipCreated(self?.zipURL)
            }
        }
    }
}
