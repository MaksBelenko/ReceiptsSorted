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
    
    
    func createHorizontalBar(percentage: CGFloat, color: UIColor) -> CALayer {
        let barLayer = CALayer()
        let barwidth = 18/20 * frameWidth * percentage
        barLayer.frame = CGRect(x: frameWidth/20, y: 14/30*frameHeight, width: barwidth, height: 14)
        barLayer.cornerRadius = 7
        barLayer.backgroundColor = color.cgColor
        
        return barLayer
    }
    
    
    func createCircleLine(from startAngle: CGFloat, to endAngle: CGFloat, ofColor color: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        let circleCenter = CGPoint(x: frameWidth/2, y: frameHeight/4)
        let circleRadius = frameWidth * 4/11
        
        let circularPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 30
        
        return shapeLayer
    }
    
    
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
                
                shapeLayer.strokeColor = UIColor(rgb: 0x34475A).cgColor
                shapeLayer.lineWidth = 31
                
                sublayers.append(shapeLayer)  //Add layers
            }
        }
        
        return sublayers
    }
}
