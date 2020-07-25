//
//  TextCreator.swift
//  ReceiptsSorted
//
//  Created by Maksim on 01/06/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class TextHelper {
    
    
    public func create(text: String, bold: Bool, fontSize: CGFloat) -> NSMutableAttributedString {
           let font = (bold) ? UIFont.arialBold(ofSize: fontSize)
                               : UIFont.arial(ofSize: fontSize)
           
           return  NSMutableAttributedString(string: "\(text)",attributes:
                   [NSAttributedString.Key.font : font,
                   NSAttributedString.Key.foregroundColor : UIColor.white])
       }
    
    
    
    public func setupLabel(inBold boldText: String, text: String) -> NSMutableAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(boldText) ",
                                                        attributes: [NSAttributedString.Key.font : UIFont.arialBold(ofSize: 18),
                                                                     NSAttributedString.Key.foregroundColor : UIColor.white])
        attributedTitle.append(NSAttributedString(string: text,
                                                  attributes: [NSAttributedString.Key.font : UIFont.arial(ofSize: 18),
                                                               NSAttributedString.Key.foregroundColor : UIColor.white]))
        
        return attributedTitle
    }
    
}
