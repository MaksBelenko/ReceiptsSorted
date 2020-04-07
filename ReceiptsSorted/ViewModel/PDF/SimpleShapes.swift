//
//  SimpleShapes.swift
//  PaymentsPDF
//
//  Created by Maksim on 06/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class SimpleShapes {
    
    var pageOffset: (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)!
    var tableRowHeight: CGFloat!
    
    
    init(tableRowHeight: CGFloat, pageOffset: (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)) {
        self.tableRowHeight = tableRowHeight
        self.pageOffset = pageOffset
    }
    
    
    
    
    
    /**
     Draw rectangle with corner radius
     - Parameter drawContext: Core Graphics context
     - Parameter pageRect: Page size rectangle
     - Parameter top: Top Offset
     */
    func drawRectWithCornerRadius(drawContext: CGContext, pageRect: CGRect, top: CGFloat, colour: UIColor = .lightFlatOrange) {
        drawContext.saveGState()

        drawContext.setFillColor(colour.cgColor)
        let rectWidth = pageRect.width - (pageOffset.left + pageOffset.right)
        let rect = CGRect(x: pageOffset.left, y: top, width: rectWidth, height: tableRowHeight)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/4).cgPath
        drawContext.addPath(roundedRect)
        drawContext.drawPath(using: .fill)

        drawContext.restoreGState()
    }
    

    /**
    Draw vertical lines that separate columns in the table
    - Parameter drawContext: Core Graphics context
    - Parameter pageRect: Page size rectangle
    - Parameter top: Top Offset
    */
    func drawTableColumnsSeparators(drawContext: CGContext, pageRect: CGRect, top: CGFloat) {
        drawContext.saveGState()
        
        drawContext.setLineWidth(2.0)
        drawContext.setStrokeColor(UIColor.white.cgColor)
        
        let placeOffsetX = getOffsetX(column: .Place, textWidth: 0, pageRect: pageRect) - 10
        drawContext.move(to: CGPoint(x: placeOffsetX, y: top))
        drawContext.addLine(to: CGPoint(x: placeOffsetX, y: top + tableRowHeight))
        drawContext.strokePath()
        
        let priceOffsetX = getOffsetX(column: .Price, textWidth: 0, pageRect: pageRect) - 100
        drawContext.move(to: CGPoint(x: priceOffsetX, y: top))
        drawContext.addLine(to: CGPoint(x: priceOffsetX, y: top + tableRowHeight))
        drawContext.strokePath()
        
        drawContext.restoreGState()
    }
    
    
    
    /**
    Draw horizontal line that separate rows in the table
    - Parameter drawContext: Core Graphics context
    - Parameter pageRect: Page size rectangle
    - Parameter top: Top Offset
    */
    func drawRowSeparatorLine(drawContext: CGContext, pageRect: CGRect, top: CGFloat) {
        drawContext.saveGState()
        drawContext.setLineWidth(2.0)
        drawContext.move(to: CGPoint(x: pageOffset.left, y: top))
        drawContext.addLine(to: CGPoint(x: pageRect.width - pageOffset.right, y: top))
        drawContext.strokePath()
        drawContext.restoreGState()
    }
    
    
    
    
    /**
    Draw gradient rectangle
    - Parameter drawContext: Core Graphics context
    - Parameter pageRect: Page size rectangle
    - Parameter top: Top Offset
    */
    func drawGradient(drawContext: CGContext, pageRect: CGRect, top: CGFloat) {
        drawContext.saveGState()

        let colours = [UIColor.white.cgColor, UIColor.wetAsphalt.cgColor]
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]

        let gradient = CGGradient(colorsSpace: colourSpace,
                                       colors: colours as CFArray,
                                    locations: colorLocations)!

        let startPoint = CGPoint(x: 0, y: top)
        let endPoint = CGPoint(x: 0, y: top + 20)
        drawContext.drawLinearGradient(gradient,
                                          start: startPoint,
                                          end: endPoint,
                                          options: [])

        drawContext.restoreGState()
    }
    
    
    
    
    
   //MARK: - Helpers
    func getOffsetX(column: TableColumn, textWidth: CGFloat, pageRect: CGRect) -> CGFloat {
        switch column {
        case .Date:
            return pageOffset.left + 10
        case .Place:
            return pageOffset.left + 150
        case .Price:
            return pageRect.width - (textWidth + pageOffset.right + 10)
        }
    }
}
