//
//  MainGraphicsViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/02/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class TopGraphicsShapes {
    
    var frameWidth: CGFloat = 100.0
    var frameHeight: CGFloat = 100.0
    
    var circleCenter: CGPoint {
        return CGPoint(x: frameWidth/5, y: frameHeight * 0.43)
    }
    
    var circleRadius: CGFloat {
        return frameWidth / 9
    }
    
    var circleRightSideOffset: CGFloat {
        return circleCenter.x + circleRadius
    }
    
    
    
    
    init(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }
    
    
    
    
    
    /**
     Creates horizontal bar as CALayer.
     - Parameter percentage: percentage of infill of the bar from left to right. Range
                             is from 0.0 to 1.0 which represents percentage from 0% to 100%
     - Parameter colour: Colour of the horizontal bar
     */
    func createHorizontalBar(percentage: CGFloat = 1, colour: UIColor, offset: CGFloat) -> CALayer {
        let barLayer = CALayer()

        let barHeight: CGFloat = 6
        let offsetY = circleCenter.y + circleRadius*3/4

        let offsetX = circleRightSideOffset + offset
        let barWidth = percentage * (frameWidth - offsetX) - offset
        
        // Set anchor point so bounds animation keeps the origin constant
        // instead of the center point
        barLayer.anchorPoint = CGPoint(x: 0, y: 0)

        barLayer.frame = CGRect(x: offsetX, y: offsetY, width: barWidth, height: barHeight)
        barLayer.cornerRadius = barHeight/2
        barLayer.backgroundColor = colour.cgColor

        return barLayer
    }
    
    
    /**
     Creates circle as CAShapeLayer
     - Parameter startAngle: Angle in radians from which circle should be drawn
     - Parameter endAngle: End angle in radians to which the circle should be drawn
     - Parameter colour: Colour of the circle represented
     */
    func createCircleLine(from startAngle: CGFloat, to endAngle: CGFloat, ofColour colour: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = colour
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = 6  //frameWidth/11
        
        return shapeLayer
    }
    
    
    
    func createCurrencyLabel() -> UILabel {
        let currencyLabel = UILabel()
        currencyLabel.text = "£"
        currencyLabel.textColor = .flatOrange
        currencyLabel.font = UIFont.arial(ofSize: 46)
        currencyLabel.textAlignment = .center
        currencyLabel.frame.size.height = 50
        currencyLabel.frame.size.width = 50
        currencyLabel.center = circleCenter
        
        currencyLabel.layer.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 4)
        
        return currencyLabel
    }
    
    
    
    func createLabel(text: String = "", textAlignment: NSTextAlignment = .right) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(rgb: 0xC6CACE)
        label.font = UIFont.arial(ofSize: 25)
        label.textAlignment = textAlignment

        return label
    }
}
