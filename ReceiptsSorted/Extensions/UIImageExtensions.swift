//
//  UIImageExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 17/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Rounds corners of UIImage
     - Parameter proportion: Proportion to minimum paramter (width or height)
                             in order to have the same look of corner radius independetly
                             from aspect ratio and actual image size
     */
    func roundCorners(proportion: CGFloat) -> UIImage {
        let minValue = min(self.size.width, self.size.height)
        let radius = minValue/proportion
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return image
    }
    
    
    
    /**
     Resizes the image to a specific width using UIGraphicsImageRenderer
     - Parameter image: Image to be resized
     - Parameter width: Width to be obtained
     */
    func resize(toWidth width: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: CGFloat(ceil(width/self.size.width * self.size.height)))
        let format = self.imageRendererFormat
        format.opaque = true
        
        let compressedImage = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return compressedImage
    }
}
