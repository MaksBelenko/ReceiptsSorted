//
//  DirectoryCreatorOperation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

final class DirectoryCreatorOperation: AsyncOperation {
    
    /// Created directory url path
    var directoryPath: String?
    
    private let directoryName: String
    private let directorySearchPath: FileManager.SearchPathDirectory
    
    
    init(directoryName: String, in directorySearchPath: FileManager.SearchPathDirectory) {
        self.directoryName = directoryName
        self.directorySearchPath = directorySearchPath
    }
    
    
//    override func cancel() {
//        super.cancel()
//    }
    
    
    
    override func main() {
        defer { self.state = .finished }
        
        let paths = NSSearchPathForDirectoriesInDomains(directorySearchPath, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let directoryURL = docURL.appendingPathComponent(directoryName)
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
        if FileManager.default.fileExists(atPath: directoryURL.absoluteString) {
            do {
                print("Removing directory \(directoryURL.path)")
                try FileManager.default.removeItem(atPath: directoryURL.path)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
        // Create the directory again
        do {
            print("Creating directory in \(directoryURL.path)")
            try FileManager.default.createDirectory(atPath: directoryURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
         directoryPath = directoryURL.path
    }
}
