//
//  AddPhotosOperation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 08/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIImage

extension AddPhotosOperation: UrlPathProvider {}

// Operation that adds photos to a directory using array of tuples
final class AddPhotosOperation: AsyncOperation {
    
    /// Directory path where the photos are written to
    var directoryPath: String?
    /// URLs of all the photos
    var photosURLs: [URL] = []
    
    /// Image dictionary should contain name of the file
    /// as a key and ImageData as data
    private let imageDataArray: [(name: String, imageData: Data)]
    private let directoryUrlPath: String?
    
    
    
    init(for imageDataArray: [(name: String, imageData: Data)], path directoryUrlPath: String? = nil) {
        self.imageDataArray = imageDataArray
        self.directoryUrlPath = directoryUrlPath
    }
    
    
    deinit {
        print("DEBUG: AddPhotosOperation deinit")
    }
    
    
//    override func cancel() {
//        super.cancel()
//    }
    
    
    
    override func main() {
        defer { self.state = .finished }
        
        // Get path from the dependancy
        let dependencyPath = dependencies
                                .compactMap { ($0 as? UrlPathProvider)?.directoryPath }
                                .first
        
        guard let path = directoryUrlPath ?? dependencyPath else { return }
        
        for element in imageDataArray {
            guard !isCancelled else { return } // Check weather operation is cancelled
            
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(element.name)
            photosURLs.append(fileURL)
            
            do {
                try element.imageData.write(to: fileURL)  // writes the image data to disk
            } catch {
                print("error saving file:", error)
            }
        }
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        directoryPath = path
    }
}
