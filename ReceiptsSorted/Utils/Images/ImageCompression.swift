//
//  ImageCompression.swift
//  ReceiptsSorted
//
//  Created by Maksim on 04/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

enum ImageCompressionEnum: String {
    case Best = "Best"
    case Decent = "Decent"
    case None = "None"
}


class ImageCompression {
    
//    var settings = Settings.shared
    
    
    /**
     Compresses the image.
     
     Image compression is needed to use less memory on device and
        create light PDFs and Zip files maintaining readability
     
     - Parameter receiptImage: image to be compressed
     */
    func compressImage(for receiptImage: UIImage, withCompression compression: CGFloat) -> Data? {
//        let imageSizeinMB = Float(receiptImage.jpegData(compressionQuality: 1.0)!.count) / powf(10, 6)
//        Log.debug(message: "size in MB = \(imageSizeinMB)")

        let  newImage = (receiptImage.size.width > 1200) ? receiptImage.resize(toWidth: 1200) : receiptImage
        
        let newImageData = newImage.jpegData(compressionQuality: compression)!
        Log.debug(message: "Size compressed in MB = \(Float(newImageData.count) / powf(10, 6))")
        
        return newImageData
    }
}
