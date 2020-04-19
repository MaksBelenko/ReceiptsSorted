//
//  LogHelper.swift
//  ReceiptsSorted
//
//  Created by Maksim on 19/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

internal class LogHelper {
    
    /**
     Creates a console DEBUG message
     - Parameter message: Message that should be logged
     - Parameter file: File path (do not need to specify)
     - Parameter function: Function name (do not need to specify)
     - Parameter line: Line number (do not need to specify)
     */
    static func debug(message: String, file: String = #file, function: String = #function, line: Int = #line ) {   // file is #file
        let fileName = file.components(separatedBy: "/").last ?? "unknown"
        print("DEBUG - [\(function) in \(fileName): Line \(line)] :  \(message)")
    }
    
    
    /**
    Creates a console EXCEPTION message
    - Parameter message: Message that should be logged
    - Parameter file: File path (do not need to specify)
    - Parameter function: Function name (do not need to specify)
    - Parameter line: Line number (do not need to specify)
    */
    static func exception(message: String, file: String, function: String = #function, line: Int = #line ) {
        let fileName = file.components(separatedBy: "/").last ?? "unknown"
        print("EXCEPTION - [\(function) in \(fileName): Line \(line)] :  \(message)")
    }
    
}
