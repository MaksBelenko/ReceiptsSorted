//
//  ImageManipulator.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/01/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ImageManipulator {
    
    func croppedInRect(image: UIImage) -> UIImage {
//        func rad(_ degree: Double) -> CGFloat {
//            return CGFloat(degree / 180.0 * .pi)
//        }

//        var rectTransform: CGAffineTransform
//        switch imageOrientation {
//        case .left:
//            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
//        case .right:
//            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
//        case .down:
//            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
//        default:
//            rectTransform = .identity
//        }
//        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)

        let imageRef = image.cgImage!.cropping(to: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let result = UIImage(cgImage: imageRef!, scale: 1, orientation: .up)
        
//        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
}
