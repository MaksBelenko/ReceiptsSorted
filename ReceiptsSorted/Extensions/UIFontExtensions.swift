//
//  UIFontExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 01/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit.UIFont

extension UIFont {
    
    static func arialBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Arial-BoldMT", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func arial(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Arial", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
