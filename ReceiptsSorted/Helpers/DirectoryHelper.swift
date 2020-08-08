//
//  DirectoryHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

class DirectoryHelper {
    
    /**
     Removes directory if the one exists
     - Parameter url: URL of the directory that is to be deleted
     */
    func removeDirectoryIfExists(url: URL) throws {
        if FileManager.default.fileExists(atPath: url.absoluteString) {
                try FileManager.default.removeItem(atPath: url.path)
        }
    }
    
    /**
     Creates directory using FileManager
     - Parameter url: URL of the directory that should be created
     - Parameter createIntermediates: If true, this method creates any nonexistent parent directories as
            part of creating the directory in path. If false, this method fails if any of the intermediate
            parent directories does not exist. This method also fails if any of the intermediate path
            elements corresponds to a file and not a directory.
     */
    func createDirectory(for url: URL, withIntermediateDirectories createIntermediates: Bool = true) throws {
        try FileManager.default.createDirectory(atPath: url.absoluteString,
                                                withIntermediateDirectories: createIntermediates,
                                                attributes: nil)
    }
}
