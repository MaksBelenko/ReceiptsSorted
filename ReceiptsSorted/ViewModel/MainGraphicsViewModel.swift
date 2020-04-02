//
//  MainGraphicsViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/02/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class MainGraphicsViewModel {
    
    var frameWidth: CGFloat = 100.0
    var frameHeight: CGFloat = 100.0
    
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
    func createHorizontalBar(percentage: CGFloat, colour: UIColor) -> CALayer {
        let barLayer = CALayer()
        let barwidth = 18/20 * frameWidth * percentage
        barLayer.frame = CGRect(x: frameWidth/20, y: 14/30*frameHeight, width: barwidth, height: 14)
        barLayer.cornerRadius = 7
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
        
        let circleCenter = CGPoint(x: frameWidth/2, y: frameHeight/4)
        let circleRadius = frameWidth * 4/11
        
        let circularPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = colour
        shapeLayer.lineWidth = frameWidth/11
        
        return shapeLayer
    }
    
    
    /**
     Creates visual gaps for the main circle in UI
     - Parameter amount: Amount of gaps that should be on the main circle
     */
    func createEmptySpaces(amount: Int) -> [CAShapeLayer]{
        
        var sublayers: [CAShapeLayer] = []
        
        for i in 1...amount*2 {
            if (i%2 == 0) {
                let shapeLayer = CAShapeLayer()
                
                let circleCenter = CGPoint(x: frameWidth/2, y: frameHeight/4)
                let circleRadius = frameWidth * 4/11
                
                let size = (3/2 * CGFloat.pi)/CGFloat(2*amount+1)
                let startPoint = 3/4 * CGFloat.pi + size*CGFloat(i-1)
                let endPoint = startPoint + size
                
                let circularPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
                shapeLayer.path = circularPath.cgPath
                
                shapeLayer.fillColor = UIColor.clear.cgColor
                
                shapeLayer.strokeColor = UIColor.wetAsphalt.cgColor
                shapeLayer.lineWidth = frameWidth/11 + 1
                
                sublayers.append(shapeLayer)  //Add layers
            }
        }
        
        return sublayers
    }
}
