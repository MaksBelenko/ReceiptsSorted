//
//  DirectoryCreatorOperation.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

extension DirectoryCreatorOperation: UrlPathProvider {}

final class DirectoryCreatorOperation: AsyncOperation {
    
    /// Created directory url path
    var directoryPath: String?
    
    private let directoryName: String
    private let directorySearchPath: FileManager.SearchPathDirectory
    
    private let directoryHelper = DirectoryHelper()
    
    
    init(directoryName: String, in directorySearchPath: FileManager.SearchPathDirectory = .documentDirectory) {
        self.directoryName = directoryName
        self.directorySearchPath = directorySearchPath
    }
    
    
    deinit {
        print("DEBUG: DirectoryCreatorOperation deinit")
    }
    
//    override func cancel() {
//        super.cancel()
//    }
    
    
    
    override func main() {
        defer { self.state = .finished }
        
        let paths = NSSearchPathForDirectoriesInDomains(directorySearchPath, .userDomainMask, true)
        let directoryString = paths[0]
        let docURL = URL(string: directoryString)!
        let directoryURL = docURL.appendingPathComponent(directoryName)
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
        do {
            try directoryHelper.removeDirectoryIfExists(url: directoryURL)
            guard !isCancelled else { return } // Check weather operation is cancelled
            try directoryHelper.createDirectory(for: directoryURL, withIntermediateDirectories: false)
        } catch {
            Log.exception(message: "Error creating directory: \(error.localizedDescription)")
            return
        }
        
        guard !isCancelled else { return } // Check weather operation is cancelled
        
        directoryPath = directoryURL.path
    }
}
