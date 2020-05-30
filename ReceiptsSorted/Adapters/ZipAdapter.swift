//
//  ZipAdapter.swift
//  ReceiptsSorted
//
//  Created by Maksim on 30/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation
import Zip

class ZipAdapter {
    
    /**
     Used for zipping files without password creation
     */
    func zipFiles(_ paths: [URL], fileName: String) throws -> URL {
        return try Zip.quickZipFiles(paths, fileName: fileName)
    }
}
