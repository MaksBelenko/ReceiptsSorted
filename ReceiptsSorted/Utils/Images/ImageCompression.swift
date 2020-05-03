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
    
    
    /**
     Compresses the image.
     
     Image compression is needed to use less memory on device and
        create lite PDFs and Zip files maintaining readability
     
     - Parameter receiptImage: image to be compressed
     */
    func compressImage(for receiptImage: UIImage) -> Data? {
        let imageSizeinMB = Float(receiptImage.jpegData(compressionQuality: 1.0)!.count) / powf(10, 6)
        Log.debug(message: "size in MB = \(imageSizeinMB)")

        var newImage = receiptImage
        
        if receiptImage.size.width > 1200 {
            newImage = resize(image: receiptImage, toWidth: 1200)
        }

        let newImageData = newImage.jpegData(compressionQuality: settings.compression)!
        Log.debug(message: "Size compressed in MB = \(Float(newImageData.count) / powf(10, 6))")
        
        return newImageData
    }
    
    
    
    /**
     Resizes the image to a specific width using UIGraphicsImageRenderer
     - Parameter image: Image to be resized
     - Parameter width: Width to be obtained
     */
    private func resize(image: UIImage, toWidth width: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: CGFloat(ceil(width/image.size.width * image.size.height)))
        let format = image.imageRendererFormat
        format.opaque = true
        
        let compressedImage = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return compressedImage
    }
}
