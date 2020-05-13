//
//  FileManagerExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

extension FileManager {
    /**
     Removes everything from "tmp" directory of the app
     */
    func cleanTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
//                print("Removing file: \(path)")
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
