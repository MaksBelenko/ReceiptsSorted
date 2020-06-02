//
//  CALayerExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit


//MARK: - Extension for shadow effect
extension CALayer {
    func applyShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
    
    func removeShadow() {
        shadowOpacity = 0
    }
}
