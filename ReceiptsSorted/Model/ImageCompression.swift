//
//  ImageCompression.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ImageCompression {
    
    var settings = Settings()
    
    
    func compressImage(for receiptImage: UIImage) -> Data? {
        let imageSizeinMB = Float(receiptImage.jpegData(compressionQuality: 1.0)!.count) / powf(10, 6)
        print("size in MB = \(imageSizeinMB)")
        
        var compression : CGFloat = 1.0
        
        if (imageSizeinMB > settings.compressedSizeInMB) {
            compression = CGFloat(settings.compressedSizeInMB / imageSizeinMB)
            let newSize = Float(receiptImage.jpegData(compressionQuality: compression)!.count) / powf(10, 6)
            print("After Compression in MB = \(newSize) and ratio = \(compression)")
        }
        
        return receiptImage.jpegData(compressionQuality: compression)
    }
    
}
