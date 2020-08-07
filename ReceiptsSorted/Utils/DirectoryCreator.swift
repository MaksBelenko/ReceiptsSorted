//
//  DirectoryCreator.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/08/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation


class DirectoryCreator {
    
    /**
     Create directory in "Documents" directory
     - Returns: Path to the created directory
     */
    func createDirectory(named directoryName: String, in directorySearchPath: FileManager.SearchPathDirectory) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(directorySearchPath, .userDomainMask, true)
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
}
