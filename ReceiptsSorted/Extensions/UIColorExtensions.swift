//
//  UIColorExtensions.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit



//MARK: - Extension for UIColor hex color representation
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}


//MARK: - Custom App Colours
extension UIColor {
    
    static let lightRed = UIColor(rgb: 0xFF6060)
    
    static let superLightFlatOrange = UIColor(rgb: 0xF39C12).withAlphaComponent(0.1)
    static let lightFlatOrange = UIColor(rgb: 0xF39C12).withAlphaComponent(0.8)

    static let indicatorContourFlatColour = UIColor(rgb: 0x4D6379)
    
    static let tickSwipeActionColour = UIColor(rgb: 0x3C556E)
    static let graySwipeColour = UIColor(rgb: 0x676767)
    
    
    static let flatBlue = UIColor(rgb: 0x34495E)
    static let flatOrangeLight = UIColor(rgb: 0xF39C12)
    static let flatOrangeDark = UIColor(rgb: 0xDD8B07)
    
    static let wetAsphalt = UIColor.dynamic(light: .flatBlue, dark: .black)
    static let flatOrange = UIColor.dynamic(light: .flatOrangeLight, dark: .flatOrangeDark)
    
    static let formTextColour = UIColor.dynamic(light: .flatBlue, dark: .white)
    static let whiteGrayDynColour = UIColor.dynamic(light: .white, dark: .systemGray6)
    static let whiteBlackDynColour = UIColor.dynamic(light: .white, dark: .black)
    static let navigationColour = UIColor.dynamic(light: .flatBlue, dark: .systemGray6)
    
    static let blackWhiteShadowColour = UIColor.dynamic(light: .black, dark: .white)

    
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {

        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: {
                switch $0.userInterfaceStyle {
                case .dark:
                    return dark
                case .light, .unspecified:
                    return light
                @unknown default:
                    assertionFailure("Unknown userInterfaceStyle: \($0.userInterfaceStyle)")
                    return light
                }
            })
        }

        // iOS 12 and earlier
        return light
    }
}
